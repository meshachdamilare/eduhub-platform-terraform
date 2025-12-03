output "primary_vnet_id" {
  value = azurerm_virtual_network.vnet_primary.id
}

output "secondary_vnet_id" {
  value = try(azurerm_virtual_network.vnet_secondary[0].id, null)
}

output "subnet_ids_primary" {
  value = { for k, s in azurerm_subnet.subnet_primary : k => s.id }
}

output "subnet_ids_secondary" {
  value = try({ for k, s in azurerm_subnet.subnet_secondary : k => s.id }, {})
}

output "resource_group_name_primary" {
  value = azurerm_resource_group.rg_primary.name
}

output "resource_group_name_sec" {
  value = try(azurerm_resource_group.rg_secondary[0].name, null)
}

output "private_dns_zone_ids" {
  value = { for name, z in azurerm_private_dns_zone.zones : name => z.id }
}