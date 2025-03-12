output "prometheus_scrape_config_name" {
  description = "Name of the Prometheus additional scrape configs ConfigMap"
  value       = kubernetes_config_map.prometheus_additional_scrape_configs.metadata[0].name
}

output "grafana_dashboards_config_name" {
  description = "Name of the Grafana dashboards ConfigMap"
  value       = kubernetes_config_map.grafana_dashboards.metadata[0].name
} 