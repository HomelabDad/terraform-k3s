output "loki_service_endpoint" {
  description = "Loki service endpoint"
  value       = "http://loki.${var.namespace}.svc.cluster.local:3100"
}

output "loki_ingress_url" {
  description = "Loki ingress URL"
  value       = "http://${var.loki_ingress_host}"
}

output "minio_service_endpoint" {
  description = "MinIO service endpoint"
  value       = "http://minio.${var.namespace}.svc.cluster.local:9000"
}

output "minio_console_url" {
  description = "MinIO console URL"
  value       = "http://minio-console.vermillion.local"
}

output "minio_credentials" {
  description = "MinIO credentials"
  value = {
    username = var.minio_root_user
    password = var.minio_root_password
  }
  sensitive = true
}

output "loki_s3_bucket" {
  description = "S3 bucket used for Loki storage"
  value       = var.loki_s3_bucket
}

output "namespace" {
  description = "Namespace where Loki stack is deployed"
  value       = var.namespace
} 