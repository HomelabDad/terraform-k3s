resource "kubernetes_manifest" "cluster_issuer_selfsigned" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "selfsigned-issuer"
    }
    spec = {
      selfSigned = {}
    }
  }
}

# Optional: Create a CA issuer that can sign certificates
resource "kubernetes_manifest" "ca_issuer" {
  depends_on = [kubernetes_manifest.cluster_issuer_selfsigned]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "local-ca"
      namespace = "cert-manager"
    }
    spec = {
      isCA        = true
      commonName  = "local-ca"
      secretName  = "local-ca-key-pair"
      duration    = "87600h" # 10 years
      renewBefore = "720h"   # 30 days
      issuerRef = {
        name  = "selfsigned-issuer"
        kind  = "ClusterIssuer"
      }
    }
  }
}

resource "kubernetes_manifest" "ca_cluster_issuer" {
  depends_on = [kubernetes_manifest.ca_issuer]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "local-ca-issuer"
    }
    spec = {
      ca = {
        secretName = "local-ca-key-pair"
      }
    }
  }
} 