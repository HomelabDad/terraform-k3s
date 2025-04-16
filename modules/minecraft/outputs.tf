output "minecraft_service_name" {
  description = "Name of the Minecraft service"
  value       = helm_release.minecraft.name
}

output "minecraft_namespace" {
  description = "Namespace of the Minecraft service"
  value       = kubernetes_namespace.minecraft.metadata[0].name
}

output "minecraft_service_ip" {
  description = "IP address of the Minecraft service (if LoadBalancer type)"
  value       = var.enable_traefik_ingress ? null : (var.service_type == "LoadBalancer" ? var.load_balancer_ip : null)
}

output "minecraft_port" {
  description = "Port of the Minecraft server"
  value       = 25565
}

output "minecraft_dns_name" {
  description = "DNS name for the Minecraft server when using Traefik"
  value       = var.enable_traefik_ingress ? var.minecraft_dns_name : null
} 