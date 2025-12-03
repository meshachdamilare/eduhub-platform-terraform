module "redis" {
  source                        = "../../modules/database/redis"
  resource_group_name           = module.networking.resource_group_name_primary
  location                      = var.location_primary
  name                          = "meshach-redis-dev-010"
  sku_name                      = "Premium"
  family                        = "P"
  capacity                      = 2
  private_endpoint_enabled      = true
  private_endpoint_subnet_id    = module.networking.subnet_ids_primary["private-endpoints"]
  redis_privatelink_dns_zone_id = module.networking.private_dns_zone_ids["privatelink.redis.cache.windows.net"]
  tags = {
    env = "dev"
  }

  depends_on = [ module.networking ]
}