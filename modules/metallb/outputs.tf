output "ip_address_pool" {
  description = "The IP address pool configured for MetalLB"
  value       = kubectl_manifest.metallb_ip_pool.yaml_body
} 