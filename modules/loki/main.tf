resource "kubernetes_namespace" "loki" {
  metadata {
    name = var.namespace
  }
}

# MinIO for S3-compatible storage backend
resource "helm_release" "minio" {
  name       = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = var.minio_helm_chart_version
  namespace  = kubernetes_namespace.loki.metadata[0].name

  values = [
    file("${path.module}/minio-values.yaml")
  ]

  set {
    name  = "auth.rootUser"
    value = var.minio_root_user
  }

  set {
    name  = "auth.rootPassword"
    value = var.minio_root_password
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  # Enable MinIO Console ingress
  set {
    name  = "console.ingress.enabled"
    value = "true"
  }

  set {
    name  = "console.ingress.ingressClassName"
    value = "traefik"
  }

  set {
    name  = "console.ingress.hosts[0]"
    value = "minio-console.vermillion.local"
  }

  set {
    name  = "console.ingress.path"
    value = "/"
  }

  set {
    name  = "console.ingress.pathType"
    value = "Prefix"
  }

  depends_on = [kubernetes_namespace.loki, var.traefik_module]
}

# Loki for log aggregation
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_helm_chart_version
  namespace  = kubernetes_namespace.loki.metadata[0].name

  values = [
    file("${path.module}/loki-values.yaml")
  ]

  set {
    name  = "loki.storage.type"
    value = "s3"
  }

  set {
    name  = "loki.storage.s3.endpoint"
    value = "http://minio.${var.namespace}.svc.cluster.local:9000"
  }

  set {
    name  = "loki.storage.s3.bucketname"
    value = var.loki_s3_bucket
  }

  set {
    name  = "loki.storage.s3.access_key_id"
    value = var.minio_root_user
  }

  set {
    name  = "loki.storage.s3.secret_access_key"
    value = var.minio_root_password
  }

  set {
    name  = "loki.storage.s3.s3forcepathstyle"
    value = "true"
  }

  set {
    name  = "loki.storage.s3.insecure"
    value = "true"
  }

  set {
    name  = "loki.storage.s3.region"
    value = "us-east-1"
  }

  # Enable Loki Ingress
  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.ingressClassName"
    value = "traefik"
  }

  set {
    name  = "ingress.hosts[0]"
    value = var.loki_ingress_host
  }

  set {
    name  = "ingress.path"
    value = "/"
  }

  set {
    name  = "ingress.pathType"
    value = "Prefix"
  }

  depends_on = [helm_release.minio, var.traefik_module]
}

# Promtail for log collection
resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = var.promtail_helm_chart_version
  namespace  = kubernetes_namespace.loki.metadata[0].name

  values = [
    file("${path.module}/promtail-values.yaml")
  ]

  set {
    name  = "loki.serviceName"
    value = "loki.${var.namespace}.svc.cluster.local"
  }

  set {
    name  = "loki.servicePort"
    value = "3100"
  }

  depends_on = [helm_release.loki]
} 