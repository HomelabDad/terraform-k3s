variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for K3s cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "traefik_load_balancer_ip" {
  description = "The static IP address for the Traefik load balancer"
  type        = string
  default     = null
}

variable "metallb_ip_range" {
  description = "The IP address range for MetalLB (format: start-end)"
  type        = string
  default     = null
}

# Minecraft-related variables
variable "minecraft_load_balancer_ip" {
  description = "The static IP address for the Minecraft server"
  type        = string
  default     = null
}

variable "minecraft_server_name" {
  description = "The name of the Minecraft server displayed in the server list"
  type        = string
  default     = "K3s Minecraft Server"
}

variable "minecraft_memory" {
  description = "Memory allocated to the Minecraft server (e.g. '2G')"
  type        = string
  default     = "2G"
}

variable "minecraft_max_players" {
  description = "Maximum number of players allowed on the Minecraft server"
  type        = number
  default     = 20
}

variable "minecraft_use_traefik" {
  description = "Whether to use Traefik to route traffic to the Minecraft server"
  type        = bool
  default     = false
}

variable "minecraft_domain_name" {
  description = "DNS name for the Minecraft server (e.g. minecraft.vermillion.local)"
  type        = string
  default     = "minecraft.vermillion.local"
}