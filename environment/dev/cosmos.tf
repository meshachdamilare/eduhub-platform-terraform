# If you want Serverless (cheaper, but single region only)

# For HA (multi-region HA)
# Disable serverless, set it to false; Enable automatic failover; Set multiple geo locations

# module "cosmos" {
#   source              = "../../modules/database/cosmos"
#   resource_group_name = module.networking.resource_group_name_primary
#   location_primary    = var.location_primary
#   account_name        = "meshach-cosmos-dev"
#   geo_locations = [
#     { location = var.location_primary, failover_priority = 0 },
#     # { location = var.location_secondary, failover_priority = 1 },
#   ]
#   enable_serverless                = true
#   private_endpoint_enabled         = true
#   private_endpoint_subnet_id       = module.networking.subnet_ids_primary["private-endpoints"]
#   cosmos_mongo_private_dns_zone_id = module.networking.private_dns_zone_ids["privatelink.mongo.cosmos.azure.com"]
# }

