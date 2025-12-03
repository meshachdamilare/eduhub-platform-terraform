
# module "blob_private" {
#   source              = "../../modules/storage"
#   env                 = var.env
#   location            = var.location_primary
#   resource_group_name = module.networking.resource_group_name_primary
#   account_name        = "lmscontentmesh"

#   account_kind = "BlobStorage"


#   public_network_access_enabled = false
#   enable_cdn                    = false

#   enable_private_endpoint      = true
#   private_endpoint_subnet_id   = module.networking.subnet_ids_primary["private-endpoints"]
#   blob_privatelink_dns_zone_id = module.networking.private_dns_zone_ids["privatelink.blob.core.windows.net"]
# }


# Public access via cdn

# module "blob_cdn" {
#   source              = "../../modules/storage"
#   env                 = var.env
#   location            = var.location_primary
#   resource_group_name = module.networking.resource_group_name_primary
#   account_name        = "lmscontent"

#   public_network_access_enabled = true  # CDN requires public origin
#   enable_cdn = true

#   # No private endpoint in this mode
#   enable_private_endpoint       = false
# }