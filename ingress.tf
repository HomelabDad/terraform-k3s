resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.9.1"  # Current stable version

  # Increase timeout
  timeout = 900 # 15 minutes instead of default

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  # Optional: Configure default SSL certificate
  # set {
  #   name  = "controller.defaultTLS.enabled"
  #   value = "true"
  # }

  # Reduce resource requests to help with deployment
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }

  # Optional: Add image pull policy to help with potential pulling issues
  set {
    name  = "controller.image.pullPolicy"
    value = "IfNotPresent"
  }
} 