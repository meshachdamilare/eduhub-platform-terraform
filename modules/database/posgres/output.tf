output "server_id" {
  value = azurerm_postgresql_flexible_server.this.id
}

output "fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}

output "ha_mode" {
  value = try(azurerm_postgresql_flexible_server.this.high_availability[0].mode, "Disabled")
}
output "private_endpoint_id" {
  value = try(azurerm_private_endpoint.this[0].id, null)
}

output "administrator_login" {
  value = azurerm_postgresql_flexible_server.this.administrator_login
}