variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for K3s cluster"
  type        = string
  default     = "~/.kube/config"
}