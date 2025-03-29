# output "prometheus_scrape_config_name" {
#   description = "Name of the Prometheus additional scrape configs ConfigMap"
#   value       = kubernetes_config_map.prometheus_additional_scrape_configs.metadata[0].name
# }

# output "grafana_dashboards_config_name" {
#   description = "Name of the Grafana dashboards ConfigMap"
#   value       = kubernetes_config_map.grafana_dashboards.metadata[0].name
# }

output "monitoring_namespace" {
  description = "The name of the monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://prometheus.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:9090"
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://grafana.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = helm_release.grafana.values[0]
  sensitive   = true
}