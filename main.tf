resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_helm_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/modules/monitoring-stack/prometheus-values.yaml")
  ]


  # Enable Grafana Ingress
  set {
    name  = "grafana.ingress.enabled"
    value = "true"
  }
  set {
    name  = "grafana.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "grafana.ingress.hosts[0]"
    value = "grafana.local"  # Or use something like grafana.192.168.1.240.nip.io
  }

  # Enable Prometheus Ingress (optional)
  set {
    name  = "prometheus.ingress.enabled"
    value = "true"
  }
  set {
    name  = "prometheus.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "prometheus.ingress.hosts[0]"
    value = "prometheus.local"  # Or use something like prometheus.192.168.1.240.nip.io
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_helm_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/modules/monitoring-stack/grafana-values.yaml")
  ]

  depends_on = [kubernetes_namespace.monitoring]
} 