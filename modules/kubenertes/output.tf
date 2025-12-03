output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity
}

output "kube_admin_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_admin_config
  sensitive = true
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}