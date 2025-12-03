output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}

output "private_endpoint_id" {
  value = try(azurerm_private_endpoint.blob[0].id, null)
}

output "cdn_hostname" {
  value = try(azurerm_cdn_endpoint.cdn_ep[0].fqdn, null)
}