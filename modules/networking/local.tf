locals {
  region_primary_slug   = replace(lower(var.location_primary), " ", "-")
  region_secondary_slug = var.enable_secondary && try(length(var.location_secondary) > 0, false) ? replace(lower(var.location_secondary), " ", "-") : "secondary-disabled"
}