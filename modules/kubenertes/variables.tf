
variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "dns_prefix" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
} # AKS nodepool subnet

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
  default = "loadBalancer"
} # With NAT GW; or "loadBalancer"

variable "vm_size" {
  type    = string
  default = "Standard_B2ms"
}

variable "node_pool_name" {
  type = string
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
