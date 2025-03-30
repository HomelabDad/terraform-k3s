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