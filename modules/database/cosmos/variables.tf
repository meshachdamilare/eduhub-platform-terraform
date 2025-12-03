variable "resource_group_name" {
  type = string
}

variable "location_primary" {
  type = string
}

variable "account_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "consistency_level" {
  type        = string
  default     = "Session"
  description = "Strong | BoundedStaleness | Session | ConsistentPrefix | Eventual"
}

# HA: define one or more geo locations with priorities 0..n
variable "geo_locations" {
  type = list(object({
    location          = string
    failover_priority = number
  }))
  # single-region default
  default = []
}

variable "enable_serverless" {
  type    = bool
  default = false
}

variable "private_endpoint_enabled" {
  type    = bool
  default = true
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "cosmos_mongo_private_dns_zone_id" {
  type = string
}
