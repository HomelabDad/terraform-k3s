resource "kubernetes_namespace" "minecraft" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "minecraft" {
  name             = "minecraft"
  repository       = "https://itzg.github.io/minecraft-server-charts"
  chart            = "minecraft"
  namespace        = kubernetes_namespace.minecraft.metadata[0].name
  create_namespace = false
  version          = "4.9.3" # Check for latest version at https://github.com/itzg/minecraft-server-charts

  # Increase timeout for initialization
  timeout = 600

  values = [
    <<-EOT
    image:
      repository: itzg/minecraft-server
      tag: latest
      pullPolicy: Always

    minecraftServer:
      eula: true
      version: ${var.minecraft_version}
      gameMode: ${var.game_mode}
      difficulty: ${var.difficulty}
      maxPlayers: ${var.max_players}
      motd: "${var.server_name}"
      memory: "${var.memory}"
      
    persistence:
      dataDir:
        enabled: true
        storageClass: ${var.storage_class}
        size: ${var.storage_size}
    
    resources:
      requests:
        cpu: ${var.cpu_request}
        memory: ${var.memory_request}
      limits:
        cpu: ${var.cpu_limit}
        memory: ${var.memory_limit}
    
    service:
      type: ${var.enable_traefik_ingress ? "NodePort" : var.service_type}
      loadBalancerIP: ${!var.enable_traefik_ingress && var.load_balancer_ip != null ? "\"${var.load_balancer_ip}\"" : "null"}
      annotations:
        ${!var.enable_traefik_ingress && var.service_type == "LoadBalancer" ? "\"metallb.universe.tf/address-pool\": \"first-pool\"" : ""}
      # Force a specific NodePort when using Traefik
      nodePorts:
        minecraft: ${var.enable_traefik_ingress ? "30565" : "null"}
    
    podAnnotations:
      backup.velero.io/backup-volumes: "datadir"
    EOT
  ]
}

# Add Traefik IngressRoute for TCP traffic when enabled
resource "kubernetes_manifest" "minecraft_ingressroute_tcp" {
  count = var.enable_traefik_ingress ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "minecraft-tcp"
      namespace = kubernetes_namespace.minecraft.metadata[0].name
    }
    spec = {
      entryPoints = ["minecraft"]
      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name = "minecraft-minecraft"
              port = 25565
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.minecraft]
} 