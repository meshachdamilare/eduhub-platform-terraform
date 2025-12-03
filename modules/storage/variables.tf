variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "account_name" {
  type        = string
  description = "Storage account name (global)."
}

variable "videos_container_name" {
  type    = string
  default = "videos"
}

variable "account_kind" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}


variable "static_content" {
  type    = bool
  default = true
}

variable "enable_cdn" {
  type    = bool
  default = true
}

variable "cdn_profile_sku" {
  type    = string
  default = "Standard_Microsoft"
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}


variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "private_endpoint_subnet_id" {
  type    = string
  default = null
}

variable "blob_privatelink_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID for privatelink.blob.core.windows.net"
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

