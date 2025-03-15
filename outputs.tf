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
  value       = helm_release.grafana.name
  sensitive   = true
} 