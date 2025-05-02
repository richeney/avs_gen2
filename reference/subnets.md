# Subnets

```shell
resource_group_name=rcheney-avs-gen2
vnet_name=rcheney-avs-gen2-vnet
```

```shell
az network vnet subnet list --resource-group $resource_group_name --vnet-name $vnet_name --query "[].{prefix:addressPrefixes[0], name:name, nsg:(networkSecurityGroup.id != null), routeTable:(routeTable.id != null), privateEndpoint:privateEndpointNetworkPolicies}|sort_by(@, &prefix)" --output table
```

```text
Prefix          Name                                      Nsg    RouteTable    PrivateEndpoint
--------------  ----------------------------------------  -----  ------------  -----------------
10.76.0.64/27   esx-cust-fdc-b15475e876ec4fa28e82da       True   True          Enabled
10.76.0.96/27   cust-fds-b15475e876ec4fa28e82da           True   True          Disabled
10.76.0.128/27  esx-lrnsxuplink-b15475e876ec4fa28e82da    False  False         Enabled
10.76.0.160/27  esx-lrnsxuplink-1-b15475e876ec4fa28e82da  False  False         Enabled
10.76.0.224/27  services-b15475e876ec4fa28e82da           True   True          Enabled
10.76.1.0/24    esx-cust-vmk1-b15475e876ec4fa28e82da      True   True          Enabled
10.76.2.0/24    esx-vmotion-vmk2-b15475e876ec4fa28e82da   True   True          Enabled
10.76.3.0/24    esx-vsan-vmk3-b15475e876ec4fa28e82da      True   True          Enabled
```

```shell
query="{endpoints:endpoints, managementNetwork:managementNetwork, networkBlock:networkBlock, vMotionNetwork:vMotionNetwork}"
az vmware private-cloud show --resource-group rcheney-avs-gen2 --name rcheney-avs-gen2 --query "$query"
```

```json
{
  "endpoints": {
    "hcxCloudManager": "https://hcx.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com/",
    "hcxCloudManagerIp": "10.76.0.37",
    "nsxtManager": "https://nsx.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com/",
    "nsxtManagerIp": "10.76.0.4",
    "vcenterIp": "10.76.0.36",
    "vcsa": "https://vc.f0e358d8bee44ad0aa5784.uksouth.avs.azure.com/"
  },
  "managementNetwork": "10.76.0.0/26",
  "networkBlock": "10.76.0.0/22",
  "vMotionNetwork": null
}
```
