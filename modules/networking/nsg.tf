locals {
  subnets_with_nsg_prim = {
    for k, v in var.subnets_primary :
    k => v
    if length(try(v.nsg_rules, [])) > 0
  }

  subnets_with_nsg_sec = {
    for k, v in var.subnets_secondary :
    k => v
    if length(try(v.nsg_rules, [])) > 0
  }
}


resource "azurerm_network_security_group" "nsg_primary" {
  for_each            = local.subnets_with_nsg_prim
  name                = "${var.env}-nsg-${each.key}-${local.region_primary_slug}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.rg_primary.name

  dynamic "security_rule" {
    for_each = each.value.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}


resource "azurerm_subnet_network_security_group_association" "assoc_primary" {
  for_each                  = local.subnets_with_nsg_prim
  subnet_id                 = azurerm_subnet.subnet_primary[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_primary[each.key].id
}

# ---------------- NSGs + Subnets (secondary) ----------------
resource "azurerm_network_security_group" "nsg_secondary" {
  for_each            = var.enable_secondary ? local.subnets_with_nsg_sec : {}
  name                = "${var.env}-nsg-${each.key}-${local.region_secondary_slug}"
  location            = var.location_secondary
  resource_group_name = azurerm_resource_group.rg_secondary[0].name

  dynamic "security_rule" {
    for_each = lookup(each.value, "nsg_rules", [])
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc_secondary" {
  for_each                  = var.enable_secondary ? local.subnets_with_nsg_sec : {}
  subnet_id                 = azurerm_subnet.subnet_secondary[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_secondary[each.key].id
}



