resource "azurerm_resource_group" "avs" {
  name     = "${var.prefix}-avs-gen2"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_virtual_network" "avs" {
  name                = "${var.prefix}-avs-gen2-vnet"
  location            = azurerm_resource_group.avs.location
  resource_group_name = azurerm_resource_group.avs.name

  address_space = ["${var.avs_address_space}"]
}


resource "azapi_resource" "avs" {
  type                      = "Microsoft.AVS/PrivateClouds@2024-09-01-preview"
  schema_validation_enabled = false
  name                      = "${var.prefix}-avs-gen2"
  parent_id                 = azurerm_resource_group.avs.id
  location                  = azurerm_resource_group.avs.location
  depends_on                = [azurerm_virtual_network.avs]

  identity {
    type = "SystemAssigned"
  }

  body = {
    zones = ["1"]
    sku = {
      name = "av64"
    }
    properties = {
      managementCluster = {
        clusterSize = 3
      }
      networkBlock     = var.avs_address_space
      dnsZone          = "Public",
      virtualNetworkId = azurerm_virtual_network.avs.id
    }
  }

  // <https://docs.github.com/en/actions/administering-github-actions/usage-limits-billing-and-administration#usage-limits
  // Maximum job execution time in a GitHub Actions workflow is 6 hours
  timeouts {
    create = "6h"
    delete = "6h"
  }
}

/*
data "azurerm_vmware_solution_private_cloud" "avs" {
  name                = azapi_resource.avs.name
  resource_group_name = azurerm_resource_group.avs.name
}
*/


/*
resource "azurerm_virtual_network_peering" "hub-to-avs" {
  name                      = "${var.prefix}-hub-to-avs"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_resource_group.avs.id

  allow_virtual_network_access           = true
  allow_forwarded_traffic                = true
  allow_gateway_transit                  = false
  use_remote_gateways                    = false
  peer_complete_virtual_networks_enabled = true // default
}

resource "azurerm_virtual_network_peering" "avs-to-hub" {
  name                      = "${var.prefix}-avs-to-hub"
  resource_group_name       = azurerm_resource_group.avs.name
  virtual_network_name      = azurerm_virtual_network.avs.name
  remote_virtual_network_id = azurerm_resource_group.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = true
  peer_complete_virtual_networks_enabled = false
  local_subnet_names = [

  ]// default
}
*/