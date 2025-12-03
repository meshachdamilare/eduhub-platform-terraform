output "account_id" {
  value = azurerm_cosmosdb_account.this.id
}

output "account_name" {
  value = azurerm_cosmosdb_account.this.name
}

output "read_endpoints" {
  value = azurerm_cosmosdb_account.this.read_endpoints
}

output "write_endpoints" {
  value = azurerm_cosmosdb_account.this.write_endpoints
}

output "private_endpoint_id" {
  value = try(azurerm_private_endpoint.this[0].id, null)
}