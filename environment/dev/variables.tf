variable "env" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location_primary" {
  type = string
}

variable "enable_secondary" {
  type = bool
}

variable "location_secondary" {
  type    = string
  default = null
}

variable "enable_nat_gateway" {
  type = bool
}

#-------------- AKS -----------------

variable "cluster_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "dns_prefix" {
  type    = string
  default = ""
}

variable "acr_id" {
  type    = string
  default = null
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "private_cluster" {
  type    = bool
  default = true
}

variable "oidc_issuer_enabled" {
  type    = bool
  default = true
}

variable "workload_identity_enabled" {
  type    = bool
  default = true
}

variable "outbound_type" {
  type    = string
  default = ""
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ms"
}

variable "node_pool_name" {
  type    = string
  default = "system"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "enable_autoscaling" {
  type    = bool
  default = true
}

variable "min_count" {
  type    = number
  default = 1
}

variable "max_count" {
  type    = number
  default = 3
}

#---------- ACR -------

variable "create_acr" {
  type    = bool
  default = true
}
variable "acr_name" {
  type    = string
  default = null
}
variable "acr_sku" {
  type    = string
  default = "Basic"
}

# ------ postgres ------

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}