resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.13.2"

  create_namespace = true

  values = [
    templatefile("${path.module}/helmValues/ingress-controller-values.yaml", {})
  ]

  depends_on = [module.aks_primary]
}

