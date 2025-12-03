module "postgres" {
  source                           = "../../modules/database/posgres"
  resource_group_name              = module.networking.resource_group_name_primary
  location                         = var.location_primary
  name                             = "meshach-pg-dev"
  postgres_version                 = "16"
  sku_name                         = "GP_Standard_D2s_v3"
  storage_mb                       = 32768
  ha_enabled                       = false
  primary_az                       = null
  standby_az                       = null
  azure_ad_auth_enabled            = false
  password_auth_enabled            = true
  administrator_login              = "pgadmin" 
  administrator_password           = "TestPassword123" 
  network_mode                     = "privatelink"
  private_endpoint_subnet_id       = module.networking.subnet_ids_primary["private-endpoints"]
  postgres_privatelink_dns_zone_id = module.networking.private_dns_zone_ids["privatelink.postgres.database.azure.com"]
  tags = {
    env = "dev"
  }

  depends_on = [ module.networking ]
}


# Null resources to create databases

locals {
  postgres_databases = [
    "edhub_auth_db",
    "assignment_service_db",
    "catalog_db",
    "eduhub_videos",
  ]
}

resource "null_resource" "create_databases" {
  depends_on = [module.postgres]

  provisioner "local-exec" {
    command = <<-EOT
      chmod +x ./scripts/createdb.sh
      POSTGRES_HOST="${module.postgres.fqdn}" \
      POSTGRES_USER="${module.postgres.administrator_login}" \
      POSTGRES_PASSWORD="${var.postgres_admin_password}" \
      ./scripts/createdb.sh
    EOT
  }
}

