# Reference

The privateClouds files are created by the portal flow.

Resolved resources array:

```json
[
    {
        "type": "Microsoft.Network/virtualNetworks",
        "apiVersion": "2019-02-01",
        "name": "[parameters('vnetName')]",
        "location": "[parameters('location')]",
        "properties": {
        "addressSpace": {
                "addressPrefixes": [
                    "10.76.0.0/22"
                ]
            }
        }
    },
    {
        "type": "Microsoft.AVS/privateClouds",
        "apiVersion": "2024-09-01-preview",
        "name": "rcheney-avs-gen2",
        "location": "uksouth",
        "dependsOn": [
            "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet"
        ],
        "tags": {
            "CreatedBy": "Richard Cheney",
            "CreatedDate": "04/28/2025",
            "DeleteDate": "04/30/2024"
        },
        "sku": {
            "name": "av64"
        },
        "zones": "[]",
        "properties": {
            "managementCluster": {
              "clusterSize": 3
            },
            "networkBlock": "10.76.0.0/22",
            "dnsZoneType": "Public",
            "virtualNetworkId": "/subscriptions/d52f9c4a-5468-47ec-9641-da4ef1916bb5/resourceGroups/rcheney/providers/Microsoft.Network/virtualNetworks/vnet-rcheney"
        }
    }
]
```

Note that the main AVS resource (and the 10.76.0.0/26 management subnet) are not exposed.

```shell
az deployment group list --resource-group rcheney-avs-gen2 --query "sort_by([?contains(name, 'cust-vnet')], &properties.timestamp) | [-1].properties.outputResources[].id" | sed 's!/subscriptions/.*/providers/!!g'
```

Output

```json
[
  "Microsoft.Network/networkSecurityGroups/cust-fds-f0e358d8bee44ad0aa5784-nsg",
  "Microsoft.Network/networkSecurityGroups/esx-cust-fdc-f0e358d8bee44ad0aa5784-nsg",
  "Microsoft.Network/networkSecurityGroups/esx-cust-vmk1-f0e358d8bee44ad0aa5784-nsg",
  "Microsoft.Network/networkSecurityGroups/esx-vmotion-vmk2-f0e358d8bee44ad0aa5784-nsg",
  "Microsoft.Network/networkSecurityGroups/esx-vsan-vmk3-f0e358d8bee44ad0aa5784-nsg",
  "Microsoft.Network/networkSecurityGroups/services-f0e358d8bee44ad0aa5784-nsg",
  "Microsoft.Network/routeTables/cust-fds-f0e358d8bee44ad0aa5784-rt",
  "Microsoft.Network/routeTables/esx-cust-fdc-f0e358d8bee44ad0aa5784-rt",
  "Microsoft.Network/routeTables/esx-cust-vmk1-f0e358d8bee44ad0aa5784-rt",
  "Microsoft.Network/routeTables/esx-vmotion-vmk2-f0e358d8bee44ad0aa5784-rt",
  "Microsoft.Network/routeTables/esx-vsan-vmk3-f0e358d8bee44ad0aa5784-rt",
  "Microsoft.Network/routeTables/services-f0e358d8bee44ad0aa5784-rt",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/cust-fds-f0e358d8bee44ad0aa5784",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/esx-cust-fdc-f0e358d8bee44ad0aa5784",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/esx-cust-vmk1-f0e358d8bee44ad0aa5784",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/esx-lrnsxuplink-1-f0e358d8bee44ad0aa5784",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/esx-lrnsxuplink-f0e358d8bee44ad0aa5784",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/esx-vmotion-vmk2-f0e358d8bee44ad0aa5784",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/esx-vsan-vmk3-f0e358d8bee44ad0aa5784",
  "Microsoft.Network/virtualNetworks/rcheney-avs-gen2-vnet/subnets/services-f0e358d8bee44ad0aa5784"
]
```
