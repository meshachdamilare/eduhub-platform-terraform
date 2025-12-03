


locals {
  use_vnet_integration = var.network_mode == "vnet"
  use_private_link     = var.network_mode == "privatelink"
  auth_ok              = var.password_auth_enabled || var.azure_ad_auth_enabled
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version    = var.postgres_version
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  backup_retention_days = var.backup_retention_days

  zone = var.ha_enabled ? var.primary_az : null

  # High Availability
   dynamic "high_availability" {
    for_each = var.ha_enabled ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.standby_az
    }
  }

  # For AAD admin
  authentication {
    active_directory_auth_enabled = var.azure_ad_auth_enabled
    password_auth_enabled         = var.password_auth_enabled
  }

  administrator_login    = var.password_auth_enabled ? var.administrator_login : null
  administrator_password = var.password_auth_enabled ? var.administrator_password : null


  # Networking
  public_network_access_enabled = false

  # VNet-integration path (NOT used with Private Link)
  delegated_subnet_id = local.use_vnet_integration ? var.delegated_subnet_id : null
  private_dns_zone_id = local.use_vnet_integration ? var.postgres_private_dns_zone_id : null

  tags = var.tags

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
      high_availability, # covers internal changes
    ]
  }
}

# Assign an Entra ID admin to the server (works with password_auth disabled)
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  count               = var.azure_ad_auth_enabled ? 1 : 0
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_flexible_server.this.name

  tenant_id      = var.tenant_id
  object_id      = var.aad_admin_object_id
  principal_name = var.aad_admin_name
  principal_type = "User" # or "Group" 
}

# Private Endpoint (used only when network_mode = "privatelink")
resource "azurerm_private_endpoint" "this" {
  count               = local.use_private_link ? 1 : 0
  name                = "pe-pg-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "pg-flex-psc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "pg-flex-dns"
    private_dns_zone_ids = [var.postgres_privatelink_dns_zone_id]
  }

  tags = var.tags
}

