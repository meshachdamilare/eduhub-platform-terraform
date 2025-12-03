variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# SKU: Premium recommended for HA + zone redundancy support
variable "sku_name" {
  type    = string
  default = "Premium"
} # or "Enterprise"

variable "family" {
  type    = string
  default = "P"
} # P for Premium

variable "capacity" {
  type    = number
  default = 1
} # size tier index

# Clustering (optional, Premium+)
variable "shard_count" {
  type    = number
  default = 0
}

# Zone redundancy (e.g., ["1","2","3"] where region supports AZs)
variable "zones" {
  type    = list(string)
  default = []
}

# Private Link
variable "private_endpoint_enabled" {
  type    = bool
  default = true
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "redis_privatelink_dns_zone_id" {
  type = string
} # privatelink.redis.cache.windows.net
