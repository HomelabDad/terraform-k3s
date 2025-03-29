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
  default     = "51.9.3"
}

variable "grafana_helm_chart_version" {
  description = "Version of the Grafana Helm chart to install"
  type        = string
  default     = "6.59.0"
} 