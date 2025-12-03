
resource "azurerm_virtual_network" "vnet_primary" {
  name                = "${var.env}-vnet-${local.region_primary_slug}"
  resource_group_name = azurerm_resource_group.rg_primary.name
  location            = var.location_primary
  address_space       = var.address_space_primary
}

resource "azurerm_virtual_network" "vnet_secondary" {
  count               = var.enable_secondary ? 1 : 0
  name                = "${var.env}-vnet-${local.region_secondary_slug}"
  resource_group_name = azurerm_resource_group.rg_secondary[0].name
  location            = var.location_secondary
  address_space       = var.address_space_secondary
}

resource "azurerm_subnet" "subnet_primary" {
  for_each             = var.subnets_primary
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg_primary.name
  virtual_network_name = azurerm_virtual_network.vnet_primary.name
  address_prefixes     = [each.value.address_prefix]
  private_endpoint_network_policies = try(each.value.disable_private_endpoint_policies, false) ? "Disabled" : "Enabled"

}

resource "azurerm_subnet" "subnet_secondary" {
  for_each             = var.enable_secondary ? var.subnets_secondary : {}
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg_secondary[0].name
  virtual_network_name = azurerm_virtual_network.vnet_secondary[0].name
  address_prefixes     = [each.value.address_prefix]
  private_endpoint_network_policies = try(each.value.disable_private_endpoint_policies, false) ? "Disabled" : "Enabled"
}
