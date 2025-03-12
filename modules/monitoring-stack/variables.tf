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