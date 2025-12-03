resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(file("kubernetes_resources/cluster-issuer.yaml"))
  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "app-of-apps" {
  manifest = yamldecode(file("kubernetes_resources/appofapps.yaml"))
  depends_on = [helm_release.argocd]
}
