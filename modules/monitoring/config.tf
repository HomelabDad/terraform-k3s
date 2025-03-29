# This module provides a way to customize the monitoring stack deployment
# You can add custom resources or configurations here

resource "kubernetes_config_map" "prometheus_additional_scrape_configs" {
  metadata {
    name      = "additional-scrape-configs"
    namespace = var.namespace
  }

  data = {
    "additional-scrape-configs.yaml" = file("${path.module}/configs/additional-scrape-configs.yaml")
  }
}

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = var.namespace
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "k3s-cluster-dashboard.json" = file("${path.module}/dashboards/k3s-cluster-dashboard.json")
  }
} 