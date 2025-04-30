# Azure VMware Solution - Gen 2

Virtual network integrated. Also known as AVS on Native.

Preview regions:

- East US
- UK South
- Japan East
- Switzerland North

az extension add --name quota
az account set --name "Richard Cheney - Application - Internal"

## Check quota

subscription_id=$(az account show --query id -otsv)
location=uksouth

az quota show --resource-name AV64 --scope /subscriptions/$subscription_id$/providers/Microsoft.Compute/locations/$location

## Providers and features

az provider register --namespace 'Microsoft.AVS'
az provider register --namespace 'Microsoft.Quota'

az provider show --namespace 'Microsoft.AVS' --query registrationState

```shell
az feature register --namespace "Microsoft.Network" --name "EnablePrivateIpPrefixAllocation"  --subscription "<Subscription ID>"
az feature registration create --namespace "Microsoft.AVS" --name "EarlyAccess"  --subscription "<Subscription ID>"
az feature registration create --namespace "Microsoft.AVS" --name "FleetGreenfield"  --subscription "<Subscription ID>"
```

## Azure VMware Solution service principal

<https://learn.microsoft.com/azure/azure-vmware/native-first-party-principle-security>

You need to be

- Cloud Application Administrator
- Application Administrator
- Global Administrator

| **Key** | **Value** |
| App ID | 1a5e141d-70dd-4594-8442-9fc46fa48686 |
| App Display Name | Avs Fleet Rp |

az ad sp update --id "1a5e141d-70dd-4594-8442-9fc46fa48686" --set accountEnabled=true

Enterprise applications > Avs Fleet Rp > Properties > Enabled for users to sign-in? Set to Yes.

## Terraform remote backend

1. Set variable

    ```shell
    myObjId=$(az ad signed-in-user show --query id -otsv)
    subscription_id=/subscriptions/$(az account show --query id -otsv)
    prefix=terraformavs
    terraformrg=rcheney-terraform
    location=uksouth
    ```

    Max 16 characters for the value of `$terraformrg`.

1. Create a storage account for the Terraform backend

    RBAC and HTTPS only, with versioning and soft delete.

    ```shell
    az group create --name $terraformrg --location $location
    storage_account_name="${prefix}$(az group show --name $terraformrg --query id -otsv | sha1sum | cut -c1-8)"
    storage_account_id=$(az storage account create --name $storage_account_name --resource-group $terraformrg --location $location \
     --min-tls-version TLS1_2 --sku Standard_LRS --https-only true --default-action "Allow" --public-network-access "Enabled" \
     --allow-shared-key-access false --allow-blob-public-access false --query id -otsv)
    az storage account blob-service-properties update --account-name $storage_account_name --resource-group $terraformrg \
      --enable-versioning --enable-delete-retention --delete-retention-days 7
    az storage container create --name tfstate --account-name $storage_account_name --auth-mode login
    ```

1. Add Storage Blob Data Contributor for use_cli

    ```shell
    az role assignment create --assignee $myObjId --scope $storage_account_id --role "Storage Blob Data Contributor"
    ```

1. Display a backend (optional)

    ```shell
    cat - <<BACKEND
    terraform {
      backend "azurerm" {
        subscription_id      = "$subscription_id"
        resource_group_name  = "$terraformrg"
        storage_account_name = "$storage_account_name"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
        use_azuread_auth     = true
      }
    }
    BACKEND
    ```

    Feel free to create a backend.tf.

## Service Principal

1. Set variables

    - identifier URI
    - object ID for the signed in user
    - subscription scope

    ```shell
    myObjId=$(az ad signed-in-user show --query id -otsv)
    identifier="api://terraform_avs_gen2"
    subscription_id=/subscriptions/$(az account show --query id -otsv)
    ```

1. Create the service principal and take ownership

    ```shell
    az ad app create --display-name ${identifier##api://} --identifier-uris $identifier
    appId=$(az ad app show --id $identifier  --query appId -otsv)
    appObjId=$(az ad app show --id $identifier --query id -otsv)
    az ad app owner add --id $identifier --owner-object-id $myObjId

    az ad sp create --id $identifier
    spObjId=$(az ad sp show --id $identifier --query id -otsv)
    ```

1. Add on assignments

    Contributor

    ```shell
    az role assignment create --assignee-object-id $spObjId --assignee-principal-type ServicePrincipal --scope $subscription_id --role "Contributor"
    ```

    RBAC Admin, on the condition that it is solely for

    - AVS Orchestrator Role (`d715fb95-a0f0-4f1c-8be6-5ad2d2767f67`) for Avs Fleet Rp service principal (`1a5e141d-70dd-4594-8442-9fc46fa48686`)
    - Network Contributor (`4d97b98b-1d4f-4787-a291-c67834d212e7`) for AzS VIS Prod App service principal (`a766fecb-91ef-4d42-8bd3-41a61b3eb0e5`)

    ```shell
    az role assignment create --assignee-object-id $spObjId --assignee-principal-type ServicePrincipal --scope $subscription_id \
      --role "Role Based Access Control Administrator" \
      --description "Allow AVS Orchestrator Role for Avs Fleet Rp, and Network Contributor for AzS VIS Prod App" \
      --condition "((@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {d715fb95-a0f0-4f1c-8be6-5ad2d2767f67} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {1a5e141d-70dd-4594-8442-9fc46fa48686}) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {4d97b98b-1d4f-4787-a291-c67834d212e7} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {a766fecb-91ef-4d42-8bd3-41a61b3eb0e5}))"
    ```

    Storage Blob Data Contributor

    Note hardcoded storage account and resource group name

    ```shell
    storage_account_id=$(az storage account list --resource-group rcheney-terraform --query "[?starts_with(name,'terraformavs')]|[0].id" -otsv)
    az role assignment create --assignee-object-id $spObjId --assignee-principal-type ServicePrincipal --scope $storage_account_id --role "Storage Blob Data Contributor"
    ```

1. Output the info for env vars / provider block

    ```shell
    echo "tenant_id = \"$(az account show --query tenantId -otsv)\""
    echo "client_id = \"$(az ad sp show --id ${identifier:-api://terraform_avs_gen2} --query id -otsv)\""
    ```

<!-- ## Managed Identity

Repeat for the managed identity.

1. Set variable

    ```shell
    prefix=terraformavs
    terraformrg=rcheney-terraform
    location=uksouth
    ```

1. Configure the managed identity, similar to the service principal

    ```shell
    az identity create --name $prefix --resource-group $terraformrg --location $location
    objectId=$(az identity show --name $prefix --resource-group $terraformrg --query principalId -otsv)
    az role assignment create --assignee-object-id $objectId --assignee-principal-type ServicePrincipal --scope $subscription_id --role "Contributor"
    az role assignment create --assignee-object-id $objectId --assignee-principal-type ServicePrincipal --scope $subscription_id \
      --role "Role Based Access Control Administrator" \
      --description "Allow AVS Orchestrator Role for Avs Fleet Rp, and Network Contributor for AzS VIS Prod App" \
      --condition "((@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {d715fb95-a0f0-4f1c-8be6-5ad2d2767f67} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {1a5e141d-70dd-4594-8442-9fc46fa48686}) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {4d97b98b-1d4f-4787-a291-c67834d212e7} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {a766fecb-91ef-4d42-8bd3-41a61b3eb0e5}))"
    storage_account_id=$(az storage account list --resource-group rcheney-terraform --query "[?starts_with(name,'terraformavs')]|[0].id" -otsv)
    az role assignment create --assignee-object-id $spObjId --assignee-principal-type ServicePrincipal --scope $storage_account_id --role "Storage Blob Data Contributor"
    ``` -->

## GitHub

1. Add on an OpenID Connect federated credential. Later.
