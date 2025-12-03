output "cache_id" {
  value = azurerm_redis_cache.this.id
}

output "hostname" {
  value = azurerm_redis_cache.this.hostname
}

output "primary_key" {
  value     = azurerm_redis_cache.this.primary_access_key
  sensitive = true
}

output "ssl_port" {
  value = azurerm_redis_cache.this.ssl_port
}

output "private_endpoint_id" {
  value = try(azurerm_private_endpoint.this[0].id, null)
}

output "redis_connection_string" {
  value     = azurerm_redis_cache.this.primary_connection_string
  sensitive = true
}