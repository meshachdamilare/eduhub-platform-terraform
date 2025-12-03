terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.50"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "azuread" {}


provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id     = "6ab1f96e-3a0e-4c7d-99e3-84dc4bf341da"
}



data "azurerm_kubernetes_cluster" "aks_primary" {
  name                = module.aks_primary.name
  resource_group_name = module.networking.resource_group_name_primary
}


provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.cluster_ca_certificate)
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.client_key)
  }
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.cluster_ca_certificate)
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks_primary.kube_config.0.client_key)
}