locals {
  sa_name = replace(lower("${var.env}${var.account_name}"), "-", "")

  cdn_needs_public_origin   = var.enable_cdn && var.cdn_profile_sku == "Standard_Microsoft" && var.public_network_access_enabled == false
  cdn_with_private_endpoint = var.enable_cdn && var.enable_private_endpoint

  missing_pe_bits = var.enable_private_endpoint && (
    var.private_endpoint_subnet_id == null || var.blob_privatelink_dns_zone_id == null
  )
}

resource "azurerm_storage_account" "sa" {
  name                     = local.sa_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = var.account_kind
  account_tier             = var.account_tier
  access_tier              = "Hot"
  account_replication_type = var.account_replication_type

  min_tls_version                   = "TLS1_2"
  public_network_access_enabled     = var.public_network_access_enabled

  tags = var.tags
}

resource "azurerm_storage_container" "videos" {
  name                  = var.videos_container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}


resource "azurerm_private_endpoint" "blob" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pe-st-${local.sa_name}-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "st-blob-psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "st-blob-dns"
    private_dns_zone_ids = [var.blob_privatelink_dns_zone_id]
  }
}

resource "azurerm_cdn_profile" "cdn" {
  count               = var.enable_cdn ? 1 : 0
  name                = "${var.env}-cdn"
  resource_group_name = var.resource_group_name
  location            = "global" 
  sku                 = var.cdn_profile_sku
  tags                = var.tags
}

resource "azurerm_cdn_endpoint" "cdn_ep" {
  count               = var.enable_cdn ? 1 : 0
  name                = "${var.env}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.cdn[0].name
  resource_group_name = var.resource_group_name
  location            = "global" 

  origin_host_header = azurerm_storage_account.sa.primary_blob_host
  origin {
    name      = "blob-origin"
    host_name = azurerm_storage_account.sa.primary_blob_host
  }
}