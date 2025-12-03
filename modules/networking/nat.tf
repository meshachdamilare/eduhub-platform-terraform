
resource "azurerm_public_ip" "nat_pip_primary" {
  count               = var.enable_nat_gateway ? var.nat_gateway_public_ips_per_region : 0
  name                = "${var.env}-nat-${local.region_primary_slug}-${count.index}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.rg_primary.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_primary" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.env}-natgw-${local.region_primary_slug}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.rg_primary.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "natpip_primary" {
  count                = var.enable_nat_gateway ? var.nat_gateway_public_ips_per_region : 0
  nat_gateway_id       = azurerm_nat_gateway.nat_primary[0].id
  public_ip_address_id = azurerm_public_ip.nat_pip_primary[count.index].id
}

resource "azurerm_subnet_nat_gateway_association" "natassoc_primary" {
  for_each       = toset(var.natgw_subnets_primary)
  subnet_id      = azurerm_subnet.subnet_primary[each.value].id
  nat_gateway_id = azurerm_nat_gateway.nat_primary[0].id
}

# ---------------- NAT (secondary, optional) ----------------
resource "azurerm_public_ip" "nat_pip_secondary" {
  count               = var.enable_secondary && var.enable_nat_gateway ? var.nat_gateway_public_ips_per_region : 0
  name                = "${var.env}-nat-${local.region_secondary_slug}-${count.index}"
  location            = var.location_secondary
  resource_group_name = azurerm_resource_group.rg_secondary[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_secondary" {
  count               = var.enable_secondary && var.enable_nat_gateway ? 1 : 0
  name                = "${var.env}-natgw-${local.region_secondary_slug}"
  location            = var.location_secondary
  resource_group_name = azurerm_resource_group.rg_secondary[0].name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "natpip_secondary" {
  count                = var.enable_secondary && var.enable_nat_gateway ? var.nat_gateway_public_ips_per_region : 0
  nat_gateway_id       = azurerm_nat_gateway.nat_secondary[0].id
  public_ip_address_id = azurerm_public_ip.nat_pip_secondary[count.index].id
}


resource "azurerm_subnet_nat_gateway_association" "natassoc_secondary" {
  for_each       = toset(var.enable_secondary ? var.natgw_subnets_secondary : [])
  subnet_id      = azurerm_subnet.subnet_secondary[each.value].id
  nat_gateway_id = azurerm_nat_gateway.nat_secondary[0].id
}
