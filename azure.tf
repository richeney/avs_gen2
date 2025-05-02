resource "azurerm_resource_group" "hub" {
  name     = "${var.prefix}-hub"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub-vnet"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  address_space = ["${var.hub_address_space}"]
}
