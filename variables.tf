variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for K3s cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "prometheus_helm_chart_version" {
  description = "Version of the Prometheus Helm chart to install"
  type        = string
  default     = "25.8.0"  # Update this to the latest stable version as needed
}

variable "grafana_helm_chart_version" {
  description = "Version of the Grafana Helm chart to install"
  type        = string
  default     = "7.0.19"  # Update this to the latest stable version as needed
} 