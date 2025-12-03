
resource "azurerm_resource_group" "rg_primary" {
  name     = "${var.env}-${var.resource_group_name}-primary"
  location = var.location_primary
}

resource "azurerm_resource_group" "rg_secondary" {
  count    = var.enable_secondary ? 1 : 0
  name     = "${var.env}-${var.resource_group_name}-sec"
  location = var.location_secondary
}