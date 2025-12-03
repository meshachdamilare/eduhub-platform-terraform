resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.18.2"

  namespace        = "cert-manager"
  create_namespace = true

  values = [
    templatefile("${path.module}/helmValues/cert-manager.yaml", {
    })
  ]

  depends_on = [module.aks_primary]

}