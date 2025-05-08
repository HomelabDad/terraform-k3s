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
      # Add Minecraft port
      minecraft:
        port: 25565
        expose: true
        exposedPort: 25565
        protocol: TCP
    
    # Enable dashboard
    dashboard:
      enabled: true
    
    # Configure logging
    logs:
      general:
        level: INFO
      access:
        enabled: true
    
    # Add additional entrypoints
    additionalEntrypoints:
      - name: minecraft
        port: 25565
        forwardedHeaders:
          insecure: true
        
    # Increase provider settings for TCP routing
    providers:
      kubernetesCRD:
        enabled: true
        allowCrossNamespace: true
        allowExternalNameServices: true
      kubernetesIngress:
        enabled: true
        allowExternalNameServices: true
    EOT
  ]
} 