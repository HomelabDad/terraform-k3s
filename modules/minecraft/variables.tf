variable "namespace" {
  description = "Kubernetes namespace for the Minecraft server"
  type        = string
  default     = "minecraft"
}

variable "minecraft_version" {
  description = "Minecraft server version"
  type        = string
  default     = "LATEST"
}

variable "game_mode" {
  description = "Game mode (survival, creative, adventure, spectator)"
  type        = string
  default     = "survival"
}

variable "difficulty" {
  description = "Game difficulty (peaceful, easy, normal, hard)"
  type        = string
  default     = "normal"
}

variable "max_players" {
  description = "Maximum number of players allowed"
  type        = number
  default     = 20
}

variable "server_name" {
  description = "Server name displayed in the server list"
  type        = string
  default     = "Kubernetes Minecraft Server"
}

variable "memory" {
  description = "Memory allocated to the Minecraft server (e.g. '2G')"
  type        = string
  default     = "2G"
}

variable "storage_class" {
  description = "Storage class for the persistent volume"
  type        = string
  default     = "local-path" # Default StorageClass in k3s
}

variable "storage_size" {
  description = "Size of the persistent volume for the Minecraft data"
  type        = string
  default     = "10Gi"
}

variable "cpu_request" {
  description = "CPU request for the Minecraft server"
  type        = string
  default     = "500m"
}

variable "memory_request" {
  description = "Memory request for the Minecraft server"
  type        = string
  default     = "1Gi"
}

variable "cpu_limit" {
  description = "CPU limit for the Minecraft server"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for the Minecraft server"
  type        = string
  default     = "3Gi"
}

variable "service_type" {
  description = "Kubernetes service type (LoadBalancer, ClusterIP, NodePort)"
  type        = string
  default     = "LoadBalancer"
}

variable "load_balancer_ip" {
  description = "Static IP address for the LoadBalancer service"
  type        = string
  default     = null
}

variable "enable_traefik_ingress" {
  description = "Whether to use Traefik as an ingress for the Minecraft server"
  type        = bool
  default     = false
}

variable "minecraft_dns_name" {
  description = "DNS name for the Minecraft server when using Traefik"
  type        = string
  default     = ""
} 