

resource "azurerm_cosmosdb_account" "this" {
  name                = var.account_name
  location            = var.location_primary
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  dynamic "geo_location" {
    for_each = var.geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
    }
  }

  automatic_failover_enabled    = length(var.geo_locations) > 1
  public_network_access_enabled = false

  consistency_policy {
    consistency_level = var.consistency_level
  }


  capabilities {
    name = "EnableMongo"
  }

  dynamic "capabilities" {
    for_each = var.enable_serverless ? [1] : []
    content {
      name = "EnableServerless"
    }
  }

  tags = var.tags
}


resource "azurerm_private_endpoint" "this" {
  count               = var.private_endpoint_enabled ? 1 : 0
  name                = "pe-cosmos-${var.account_name}"
  location            = var.location_primary
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "cosmos-mongo-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["MongoDB"]
  }

  private_dns_zone_group {
    name                 = "cosmos-mongo-dns"
    private_dns_zone_ids = [var.cosmos_mongo_private_dns_zone_id]
  }

  tags = var.tags
}