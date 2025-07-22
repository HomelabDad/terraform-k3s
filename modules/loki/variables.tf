variable "namespace" {
  description = "Kubernetes namespace where the Loki stack will be deployed"
  type        = string
  default     = "logging"
}

variable "minio_helm_chart_version" {
  description = "Version of the MinIO Helm chart to install"
  type        = string
  default     = "13.2.0"
}

variable "minio_root_user" {
  description = "MinIO root user"
  type        = string
  default     = "minioadmin"
}

variable "minio_root_password" {
  description = "MinIO root password"
  type        = string
  default     = "minioadmin"
  sensitive   = true
}

variable "loki_helm_chart_version" {
  description = "Version of the Loki Helm chart to install"
  type        = string
  default     = "5.41.3"
}

variable "loki_s3_bucket" {
  description = "S3 bucket name for Loki storage"
  type        = string
  default     = "loki-logs"
}

variable "loki_ingress_host" {
  description = "Ingress host for Loki"
  type        = string
  default     = "loki.vermillion.local"
}

variable "promtail_helm_chart_version" {
  description = "Version of the Promtail Helm chart to install"
  type        = string
  default     = "6.15.3"
}

variable "traefik_module" {
  description = "Reference to the Traefik module"
  type        = any
} 