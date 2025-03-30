resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  version          = "24.0.0" # Check for latest version

  # Increase timeout
  timeout = 900

  values = [
    <<-EOT
    deployment:
      replicas: 1
    
    service:
      type: LoadBalancer
      # Specify static IP from MetalLB pool range
      loadBalancerIP: ${var.load_balancer_ip != null ? "\"${var.load_balancer_ip}\"" : "null"}
      annotations:
        "metallb.universe.tf/allow-shared-ip": "traefik"
        "metallb.universe.tf/address-pool": "first-pool"
    
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "300m"
        memory: "256Mi"
    
    # Basic dashboard and API configuration
    ports:
      web:
        expose: true
      websecure:
        expose: true
    
    # Enable dashboard
    dashboard:
      enabled: true
    
    # Configure logging
    logs:
      general:
        level: INFO
      access:
        enabled: true
    EOT
  ]
} 