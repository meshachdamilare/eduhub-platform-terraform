variable "env" {
  type = string
}
variable "location_primary" {
  type = string
}

variable "location_secondary" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "enable_secondary" {
  type    = bool
  default = false
}

variable "address_space_primary" {
  type = list(string)
}

variable "address_space_secondary" {
  type = list(string)
}

variable "subnets_primary" {
  type = map(object({
    address_prefix = string
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
    disable_private_endpoint_policies = optional(bool, false)
  }))
}


# Subnet CIDRs (secondary)
variable "subnets_secondary" {
  type = map(object({
    address_prefix = string
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
    disable_private_endpoint_policies = optional(bool, false)
  }))

}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "nat_gateway_public_ips_per_region" {
  type    = number
  default = 1
}

variable "natgw_subnets_primary" {
  type    = list(string)
  default = []
   description = "List of subnets that will be associated with NAT Gateway"
}

variable "natgw_subnets_secondary" {
  type    = list(string)
  default = []
   description = "List of subnets that will be associated with NAT Gateway"
}


# Private DNS zones for PaaS private endpoints
variable "private_dns_zones" {
  description = "Map of zone name => (bool link primary, bool link secondary)"
  type = map(object({
    link_primary   = bool
    link_secondary = bool
  }))

  default = {
    # Data-plane zones
    "privatelink.postgres.database.azure.com" = { link_primary = true, link_secondary = true }
    "privatelink.redis.cache.windows.net"     = { link_primary = true, link_secondary = true }
    "privatelink.mongo.cosmos.azure.com"      = { link_primary = true, link_secondary = true }
    "privatelink.blob.core.windows.net"       = { link_primary = true, link_secondary = true }
  }
}