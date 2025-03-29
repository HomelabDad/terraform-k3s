output "namespace" {
  description = "The name of the portainer namespace"
  value       = kubernetes_namespace.portainer.metadata[0].name
}

output "url" {
  description = "URL to access Portainer"
  value       = "http://portainer.${kubernetes_namespace.portainer.metadata[0].name}.svc.cluster.local:9000"
} 