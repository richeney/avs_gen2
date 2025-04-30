# Role Definitions

```shell
az role definition list --query "[?contains(roleName,'AVS')].{permissions:permissions, name:name, roleName:roleName} --output jsonc"
```

Output:

```json
[
  {
    "name": "d715fb95-a0f0-4f1c-8be6-5ad2d2767f67",
    "permissions": [
      {
        "actions": [
          "Microsoft.Authorization/roleAssignments/read",
          "Microsoft.Resources/subscriptions/resourcegroups/read",
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/operationStatuses/read",
          "Microsoft.Resources/deployments/operations/read",
          "Microsoft.Resources/deployments/delete",
          "Microsoft.Resources/deployments/read",
          "Microsoft.Network/virtualHubs/delete",
          "Microsoft.Network/publicIPAddresses/delete",
          "Microsoft.Network/networkInterfaces/delete",
          "Microsoft.Network/networkInterfaces/write",
          "Microsoft.Network/networkInterfaces/join/action",
          "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/delete",
          "Microsoft.Network/virtualNetworks/subnets/delete",
          "Microsoft.Network/networkIntentPolicies/read",
          "Microsoft.Network/networkIntentPolicies/delete",
          "Microsoft.Network/networkIntentPolicies/write",
          "Microsoft.Network/networkSecurityGroups/delete",
          "Microsoft.Network/networkSecurityGroups/write",
          "Microsoft.Network/networkSecurityGroups/read",
          "Microsoft.Network/networkSecurityGroups/join/action",
          "Microsoft.Network/networkSecurityGroups/securityRules/read",
          "Microsoft.Network/networkSecurityGroups/securityRules/write",
          "Microsoft.Network/networkSecurityGroups/securityRules/delete",
          "Microsoft.Network/virtualNetworks/subnets/write",
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/write",
          "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/read",
          "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/delete",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
          "Microsoft.Network/virtualHubs/write",
          "Microsoft.Network/publicIPAddresses/write",
          "Microsoft.Network/publicIPAddresses/read",
          "Microsoft.Network/virtualHubs/ipConfigurations/write",
          "Microsoft.Network/networkSecurityGroups/securityRules/read",
          "Microsoft.Network/virtualHubs/ipConfigurations/read",
          "Microsoft.Network/virtualHubs/bgpConnections/write",
          "Microsoft.Network/virtualHubs/bgpConnections/read",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
          "Microsoft.Network/virtualNetworks/peer/action",
          "Microsoft.Network/locations/operations/read",
          "Microsoft.Network/locations/operationResults/read",
          "Microsoft.Network/networkInterfaces/read",
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/write",
          "Microsoft.Network/virtualNetworks/subnets/read",
          "Microsoft.Network/routeTables/read",
          "Microsoft.Network/routeTables/write",
          "Microsoft.Network/routeTables/delete",
          "Microsoft.Network/routeTables/join/action",
          "Microsoft.Network/routeTables/routes/read",
          "Microsoft.Network/routeTables/routes/write",
          "Microsoft.Network/routeTables/routes/delete",
          "Microsoft.Network/virtualNetworks/join/action"
        ],
        "condition": null,
        "conditionVersion": null,
        "dataActions": [],
        "notActions": [],
        "notDataActions": []
      },
      {
        "actions": [
          "Microsoft.Authorization/roleAssignments/delete"
        ],
        "condition": "(!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals{d715fb95a0f04f1c8be65ad2d2767f67, 4d97b98b1d4f4787a291c67834d212e7, 49fc33c1886f4b21a00e1d9993234734}",
        "conditionVersion": "2.0",
        "dataActions": [],
        "notActions": [],
        "notDataActions": []
      }
    ],
    "roleName": "AVS Orchestrator Role"
  },
  {
    "name": "49fc33c1-886f-4b21-a00e-1d9993234734",
    "permissions": [
      {
        "actions": [
          "Microsoft.Network/networkInterfaces/read",
          "Microsoft.Network/networkInterfaces/write",
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/write",
          "Microsoft.Network/virtualNetworks/peer/action",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
          "Microsoft.Network/virtualNetworks/subnets/read",
          "Microsoft.Network/virtualNetworks/subnets/write",
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/networkSecurityGroups/join/action",
          "Microsoft.Network/routeTables/join/action",
          "Microsoft.Network/serviceEndpointPolicies/join/action",
          "Microsoft.Network/natGateways/join/action",
          "Microsoft.Network/networkIntentPolicies/join/action",
          "Microsoft.Network/ddosProtectionPlans/join/action",
          "Microsoft.Network/networkManagers/ipamPools/associateResourcesToPool/action",
          "Microsoft.BareMetal/peeringSettings/read"
        ],
        "condition": null,
        "conditionVersion": null,
        "dataActions": [],
        "notActions": [],
        "notDataActions": []
      },
      {
        "actions": [
          "Microsoft.Authorization/roleAssignments/delete"
        ],
        "condition": "(!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals{49fc33c1886f4b21a00e1d9993234734}",
        "conditionVersion": "2.0",
        "dataActions": [],
        "notActions": [],
        "notDataActions": []
      }
    ],
    "roleName": "AVS on Fleet VIS Role"
  }
]
```
