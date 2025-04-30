resource "azurerm_resource_group" "avs" {
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_virtual_network" "avs" {
  name                = "${var.identifier}-vnet"
  location            = azurerm_resource_group.avs.location
  resource_group_name = azurerm_resource_group.avs.name

  address_space = ["${var.address_space}"]
}

resource "azapi_resource" "avs" {
  type                      = "Microsoft.AVS/PrivateClouds@2024-09-01-preview"
  schema_validation_enabled = false
  name                      = var.identifier
  parent_id                 = azurerm_resource_group.avs.id
  location                  = azurerm_resource_group.avs.location
  depends_on                = [azurerm_virtual_network.avs]

  identity {
    type = "SystemAssigned"
  }

  body = {
    zones = ["1"]
    sku = {
      name = "AV64"
    }
    properties = {
      managementCluster = {
        clusterSize = 3
      }
      networkBlock     = var.address_space
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
