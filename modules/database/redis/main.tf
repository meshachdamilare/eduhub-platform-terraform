


resource "azurerm_redis_cache" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name
  family   = var.family
  capacity = var.capacity

  shard_count                   = var.shard_count
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  zones                         = var.zones

  non_ssl_port_enabled = false

  tags = var.tags
}


# Private Endpoint
resource "azurerm_private_endpoint" "this" {
  count               = var.private_endpoint_enabled ? 1 : 0
  name                = "pe-redis-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "redis-psc"
    private_connection_resource_id = azurerm_redis_cache.this.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "redis-dns"
    private_dns_zone_ids = [var.redis_privatelink_dns_zone_id]
  }

  tags = var.tags
}
