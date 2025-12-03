variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "name" {
  type = string
}
variable "postgres_version" {
  type = string
}

variable "sku_name" {
  type = string
} # e.g., "GP_Standard_D4s_v5"

variable "storage_mb" {
  type = number
} # e.g., 32768

variable "backup_retention_days" {
  type    = number
  default = 7
}
variable "tags" {
  type    = map(string)
  default = {}
}

# HA
variable "ha_enabled" {
  type    = bool
  default = true
}

variable "primary_az" {
  type    = string
  default = "1"
}

variable "standby_az" {
  type    = string
  default = null
} # e.g., "2"


variable "azure_ad_auth_enabled" {
  type    = bool
  default = false
}
variable "password_auth_enabled" {
  type    = bool
  default = true
}

# optional AAD admin inputs (nullable)
variable "aad_admin_object_id" {
  type        = string
  default     = null
  description = "Object ID of the Entra ID user/group/SP to set as server admin"
}
variable "aad_admin_name" {
  type        = string
  default     = null
  description = "Display name of the admin principal"
}
variable "tenant_id" {
  type        = string
  default     = null
  description = "Tenant GUID"
}

# password admin (only needed if password_auth_enabled = true)
variable "administrator_login" {
  type    = string
  default = null
}
variable "administrator_password" {
  type      = string
  default   = null
  sensitive = true
}

# Networking mode: "vnet" or "privatelink"
variable "network_mode" {
  type    = string
  default = "vnet"
  validation {
    condition     = contains(["vnet", "privatelink"], var.network_mode)
    error_message = "network_mode must be 'vnet' or 'privatelink'."
  }
}

# VNET integration (private access)
variable "delegated_subnet_id" {
  type    = string
  default = null
}

variable "postgres_private_dns_zone_id" {
  type    = string
  default = null
}

# Private Endpoint
variable "private_endpoint_subnet_id" {
  type    = string
  default = null
}
variable "postgres_privatelink_dns_zone_id" {
  type    = string
  default = null
}
