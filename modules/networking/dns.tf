
resource "azurerm_private_dns_zone" "zones" {
  for_each            = var.private_dns_zones
  name                = each.key
  resource_group_name = azurerm_resource_group.rg_primary.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_primary" {
  for_each              = { for k, v in var.private_dns_zones : k => v if v.link_primary }
  name                  = "${var.env}-${local.region_primary_slug}-link-${replace(each.key, ".", "-")}"
  resource_group_name   = azurerm_resource_group.rg_primary.name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.key].name
  virtual_network_id    = azurerm_virtual_network.vnet_primary.id
  depends_on = [azurerm_private_dns_zone.zones] 
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_secondary" {
  for_each              = var.enable_secondary ? { for k, v in var.private_dns_zones : k => v if v.link_secondary } : {}
  name                  = "${var.env}-${local.region_secondary_slug}-link-${replace(each.key, ".", "-")}"
  resource_group_name   = azurerm_resource_group.rg_primary.name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.key].name
  virtual_network_id    = azurerm_virtual_network.vnet_secondary[0].id
  depends_on = [azurerm_private_dns_zone.zones] 
}
