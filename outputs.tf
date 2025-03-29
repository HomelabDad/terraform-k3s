# Monitoring Stack Outputs
output "monitoring_urls" {
  description = "URLs for monitoring services"
  value = {
    prometheus_url = module.monitoring.prometheus_url
    grafana_url    = module.monitoring.grafana_url
  }
}

output "monitoring_sensitive" {
  description = "Sensitive monitoring information"
  value = {
    namespace              = module.monitoring.monitoring_namespace
    grafana_admin_password = module.monitoring.grafana_admin_password
  }
  sensitive = true
}

# Traefik Outputs
output "traefik_sensitive" {
  description = "Sensitive Traefik information"
  value = {
    helm_release = module.traefik.helm_release
  }
  sensitive = true
}

# Portainer Outputs
output "portainer_url" {
  description = "URL for Portainer service"
  value       = module.portainer.url
}

output "portainer_sensitive" {
  description = "Sensitive Portainer information"
  value = {
    namespace = module.portainer.namespace
  }
  sensitive = true
}

# MetalLB Outputs
output "metallb_sensitive" {
  description = "Sensitive MetalLB information"
  value = {
    ip_address_pool = module.metallb.ip_address_pool
  }
  sensitive = true
} 