# Azure VMware Solution - Gen 2

Working notes on testing out AVS on Native. Virtual network integrated. Also known as AVS on Native.

Keen to automate with Terraform to enable customer / partner demos which was always difficult with AVS Gen 1 with the ExpressRoute Global Reach element and hardware.

There is no support yet in azurerm for Gen 2 (I believe) as I don't think the Go SDK has caught up. Anyway, use azapi in the short term.

Considerations

1. There is a requirement for privileged access to assign roles to two standard service principals. Show least privilege version.
1. This is an automated vnet injection of AVS using bare metal Azure fleet. Takes 4-6 hours which may blow the
1. Running `terraform destroy` is likely to fail. May need to document a hybrid destroy process.

## Background

<https://learn.microsoft.com/azure/azure-vmware/native-introduction>

Preview regions:

- East US
- UK South
- Japan East
- Switzerland North

## Tooling

- Ubuntu on WSL
- Azure CLI
- GitHub CLI
- git, jq, etc

```shell
az extension add --name vmware
```

### Check quota

```shell
subscription_id=$(az account show --query id -otsv)
location=uksouth
az quota show --resource-name AV64 --scope /subscriptions/$subscription_id$/providers/Microsoft.Compute/locations/$location
```

⚠️ No, this is not correct. Find out how the quota is done.

### Providers and features

az provider register --namespace 'Microsoft.AVS'
az provider register --namespace 'Microsoft.Quota'

az provider show --namespace 'Microsoft.AVS' --query registrationState

```shell
az feature register --namespace "Microsoft.Network" --name "EnablePrivateIpPrefixAllocation"  --subscription "<Subscription ID>"
az feature registration create --namespace "Microsoft.AVS" --name "EarlyAccess"  --subscription "<Subscription ID>"
az feature registration create --namespace "Microsoft.AVS" --name "FleetGreenfield"  --subscription "<Subscription ID>"
```

### Azure VMware Solution service principal

<https://learn.microsoft.com/azure/azure-vmware/native-first-party-principle-security>

You need to be

- Cloud Application Administrator
- Application Administrator
- Global Administrator

| **Key** | **Value** |
|---|---|
| App ID | 1a5e141d-70dd-4594-8442-9fc46fa48686 |
| App Display Name | Avs Fleet Rp |

az ad sp update --id "1a5e141d-70dd-4594-8442-9fc46fa48686" --set accountEnabled=true

Enterprise applications > Avs Fleet Rp > Properties > Enabled for users to sign-in? Set to Yes.

## Intro

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

1. Add Storage Blob Data Contributor for personal CLI token use

    ```shell
    az role assignment create --assignee $myObjId --scope $storage_account_id --role "Storage Blob Data Contributor"
    ```

    Allows `use_cli = true`.

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

    **Contributor**

    ```shell
    az role assignment create --assignee-object-id $spObjId --assignee-principal-type ServicePrincipal --scope $subscription_id --role "Contributor"
    ```

    **RBAC Admin**, on the condition that it is solely for

    | Name | Object ID | Role | Role ID |
    |---|---|---|---|
    | Avs Fleet Rp | `1a5e141d-70dd-4594-8442-9fc46fa48686` | AVS Orchestrator Role | `d715fb95-a0f0-4f1c-8be6-5ad2d2767f67` |
    | AzS VIS Prod App  | `a766fecb-91ef-4d42-8bd3-41a61b3eb0e5` | Network Contributor | `4d97b98b-1d4f-4787-a291-c67834d212e7` |

    ```shell
    az role assignment create --assignee-object-id $spObjId --assignee-principal-type ServicePrincipal --scope $subscription_id \
      --role "Role Based Access Control Administrator" \
      --description "Allow AVS Orchestrator Role for Avs Fleet Rp, and Network Contributor for AzS VIS Prod App" \
      --condition "((@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {d715fb95-a0f0-4f1c-8be6-5ad2d2767f67} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {1a5e141d-70dd-4594-8442-9fc46fa48686}) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {4d97b98b-1d4f-4787-a291-c67834d212e7} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {a766fecb-91ef-4d42-8bd3-41a61b3eb0e5}))"
    ```

    **Storage Blob Data Contributor**

    Note hardcoded storage account and resource group name.

    ```shell
    terraformrg="rcheney-terraform"
    prefix="terraformavs"
    storage_account_id=$(az storage account list --subscription $backend_subscription_id --resource-group "$terraformrg" --query "[?starts_with(name,'"$prefix"')]|[0].id" -otsv)
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

You will need the gh CLI and be authenticated with `gh auth login`. (You can check current status with `gh auth status`.)

1. Set the default repo

    Manually

    ```shell
    gh repo set-default richeney/avs_gen2
    ```

    More automated

    ```shell
    gh repo set-default $(git remote -v | grep ^origin | awk '{print $2}' | uniq | sed -E 's|https://github.com/||; s|\.git||')
    ```

    Output

    ```shell
    ✓ Set richeney/avs_gen2 as the default repository for the current directory
    ```

1. Set additional variables

    ```shell
    identifier="api://terraform_avs_gen2"
    avs_subscription_id=$(az account show --name "Azure VMware Solution" --query id -otsv)
    prefix="terraformavs"
    terraformrg="rcheney-terraform"
    backend_subscription_id=$avs_subscription_id

    client_id=$(az ad app show --id $identifier --query appId -otsv)
    tenant_id=$(az account show --name $avs_subscription_id --query tenantId -otsv)
    storage_account_name=$(az storage account list --subscription $backend_subscription_id --resource-group "$terraformrg" --query "[?starts_with(name,'"$prefix"')]|[0].name" -otsv)
    ```

1. Create the GitHub Actions variables

    ```shell
    gh variable set ARM_TENANT_ID --body "$tenant_id"
    gh variable set ARM_SUBSCRIPTION_ID --body "$avs_subscription_id"
    gh variable set ARM_CLIENT_ID --body "$client_id"
    gh variable set BACKEND_AZURE_SUBSCRIPTION_ID --body "$backend_subscription_id"
    gh variable set BACKEND_AZURE_RESOURCE_GROUP_NAME --body "terraform"
    gh variable set BACKEND_AZURE_STORAGE_ACCOUNT_NAME --body "$storage_account_name"
    gh variable set BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME --body "tfstate"
    gh repo view --json nameWithOwner --template '{{printf "https://github.com/%s/settings/variables/actions\n" .nameWithOwner}}'
    ```

    Note that the backend subscription and resource group aren't really needed by the workflow, but having that in the variables makes it easier for us humans to find it.

1. Create the OpenID Connect configuration

    ```shell
    oidc_credential=$(jq -c . <<CRED
    {
        "name": "${identifier##api://}",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "$(gh repo view --json nameWithOwner --template '{{printf "repo:%s:ref:refs/heads/main" .nameWithOwner}}')",
        "description": "Terraform service principal with identifierUri $identifier, via OpenID Connect",
        "audiences": [
            "api://AzureADTokenExchange"
        ]
    }
    CRED
    )

    az ad app federated-credential create --id $identifier --parameters "$oidc_credential"
    ```

## Workflow

Add pics / steps for

1. GitHub repo

gh workflow view terraform.yml --web

1.

gh workflow list
NAME                               STATE   ID
Terraform GitHub Actions Workflow  active  159221758

gh workflow view "Terraform GitHub Actions Workflow"
Terraform GitHub Actions Workflow - terraform.yml
ID: 159221758

Total runs 1
Recent runs
   TITLE            WORKFLOW                           BRANCH  EVENT              ID
*  Terraform Apply  Terraform GitHub Actions Workflow  main    workflow_dispatch  14754424669

To see more runs for this workflow, try: gh run list --workflow terraform.yml
To see the YAML for this workflow, try: gh workflow view terraform.yml --yaml

gh workflow run --help
gh workflow run
gh workflow run terraform.yml
gh run list --workflow terraform.yml

gh workflow view terraform.yml --yaml

gh run watch && notify-send "run is done!"

~/git/avs (main) $ az vmware private-cloud list --resource-group rcheney-avs-gen2 --query "[0].provisioningState"
"Building"

```shell
az vmware private-cloud list --resource-group rcheney-avs-gen2
```

```json
[
  {
    "availability": {
      "strategy": "SingleZone",
      "zone": 1
    },
    "encryption": {
      "status": "Disabled"
    },
    "endpoints": {
      "hcxCloudManager": "https://hcx.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com/",
      "hcxCloudManagerIp": "10.76.0.37",
      "nsxtManager": "https://nsx.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com/",
      "nsxtManagerIp": "10.76.0.4",
      "vcenterIp": "10.76.0.36",
      "vcsa": "https://vc.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com/"
    },
    "externalCloudLinks": [],
    "id": "/subscriptions/d52f9c4a-5468-47ec-9641-da4ef1916bb5/resourceGroups/rcheney-avs-gen2/providers/Microsoft.AVS/privateClouds/rcheney-avs-gen2",
    "identitySources": [],
    "internet": "Disabled",
    "location": "uksouth",
    "managementCluster": {
      "clusterId": 1,
      "clusterSize": 3,
      "hosts": [
        "esx65-r92.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com",
        "esx65-r62.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com",
        "esx65-r70.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com"
      ],
      "provisioningState": "Building",
      "vsanDatastoreName": "vsanDatastore"
    },
    "managementNetwork": "10.76.0.0/26",
    "name": "rcheney-avs-gen2",
    "networkBlock": "10.76.0.0/22",
    "nsxPublicIpQuotaRaised": "Disabled",
    "nsxtCertificateThumbprint": "04D47C41E0A39866F4E6A9921308E9AC5DC6B823",
    "provisioningState": "Building",
    "resourceGroup": "rcheney-avs-gen2",
    "sku": {
      "name": "av64"
    },
    "tags": {},
    "type": "Microsoft.AVS/privateClouds",
    "vcenterCertificateThumbprint": "A7C39E7B7F4D4E46DE6721FE98C9059C6ED8B14A",
    "vmotionNetwork": "10.76.2.0/24"
  }
]
```