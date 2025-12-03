resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "8.3.7"

  create_namespace = true

  values = [
    templatefile("${path.module}/helmValues/argocd-values.yaml", {
    })
  ]
  depends_on = [module.aks_primary]
}


