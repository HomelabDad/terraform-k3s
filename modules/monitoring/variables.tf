variable "namespace" {
  description = "Kubernetes namespace where the monitoring stack will be deployed"
  type        = string
}

variable "prometheus_additional_scrape_configs" {
  description = "Additional scrape configurations for Prometheus"
  type        = string
  default     = ""
}

variable "grafana_additional_datasources" {
  description = "Additional datasources for Grafana"
  type        = list(map(string))
  default     = []
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

variable "traefik_module" {
  description = "Reference to the Traefik module"
  type        = any
} 