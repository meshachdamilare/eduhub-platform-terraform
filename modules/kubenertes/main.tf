
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled   = var.private_cluster

  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  default_node_pool {
    name                 = var.node_pool_name
    vm_size              = var.vm_size
    node_count           = var.node_count
    vnet_subnet_id       = var.vnet_subnet_id
    auto_scaling_enabled = var.enable_autoscaling
    min_count            = var.enable_autoscaling ? var.min_count : null
    max_count            = var.enable_autoscaling ? var.max_count : null
    upgrade_settings { max_surge = "25%" }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = var.outbound_type
  }

  identity { type = "SystemAssigned" }

  tags = var.tags

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}