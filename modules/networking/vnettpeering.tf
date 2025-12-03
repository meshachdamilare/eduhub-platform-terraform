

resource "azurerm_virtual_network_peering" "primary_to_secondary" {
  count                        = var.enable_secondary ? 1 : 0
  name                         = "${var.env}-${local.region_primary_slug}-to-${local.region_secondary_slug}"
  resource_group_name          = azurerm_resource_group.rg_primary.name
  virtual_network_name         = azurerm_virtual_network.vnet_primary.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_secondary[0].id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true

  depends_on = [
    azurerm_subnet.subnet_primary,
    azurerm_subnet_network_security_group_association.assoc_primary,
    azurerm_subnet_nat_gateway_association.natassoc_primary,
    azurerm_nat_gateway_public_ip_association.natpip_primary,

    azurerm_subnet.subnet_secondary,
    azurerm_subnet_network_security_group_association.assoc_secondary,
    azurerm_subnet_nat_gateway_association.natassoc_secondary,
    azurerm_nat_gateway_public_ip_association.natpip_secondary,
  ]
}

resource "azurerm_virtual_network_peering" "secondary_to_primary" {
  count                        = var.enable_secondary ? 1 : 0
  name                         = "${var.env}-${local.region_secondary_slug}-to-${local.region_primary_slug}"
  resource_group_name          = azurerm_resource_group.rg_secondary[0].name
  virtual_network_name         = azurerm_virtual_network.vnet_secondary[0].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_primary.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true

  depends_on = [
    azurerm_subnet.subnet_primary,
    azurerm_subnet_network_security_group_association.assoc_primary,
    azurerm_subnet_nat_gateway_association.natassoc_primary,
    azurerm_nat_gateway_public_ip_association.natpip_primary,

    azurerm_subnet.subnet_secondary,
    azurerm_subnet_network_security_group_association.assoc_secondary,
    azurerm_subnet_nat_gateway_association.natassoc_secondary,
    azurerm_nat_gateway_public_ip_association.natpip_secondary,
  ]
}
