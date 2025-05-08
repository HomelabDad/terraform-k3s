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

# Minecraft outputs
output "minecraft_server_ip" {
  description = "The IP address of the Minecraft server"
  value       = module.minecraft.minecraft_service_ip
}

output "minecraft_server_port" {
  description = "The port of the Minecraft server"
  value       = module.minecraft.minecraft_port
}

output "minecraft_dns_name" {
  description = "The DNS name of the Minecraft server when using Traefik"
  value       = module.minecraft.minecraft_dns_name
}

output "minecraft_connection_info" {
  description = "The connection information for the Minecraft server"
  value       = var.minecraft_use_traefik ? "${var.traefik_load_balancer_ip}:25565 or ${module.minecraft.minecraft_dns_name}" : "${module.minecraft.minecraft_service_ip != null ? module.minecraft.minecraft_service_ip : "your-server-ip"}:${module.minecraft.minecraft_port}"
}

output "minecraft_node_access" {
  description = "Alternative access method via NodePort (when using Traefik)"
  value       = var.minecraft_use_traefik ? "Use any node IP with port 30565" : null
} 