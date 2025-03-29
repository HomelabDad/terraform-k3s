# Portainer namespace
resource "kubernetes_namespace" "portainer" {
  metadata {
    name = "portainer"
  }
}

# Portainer ServiceAccount
resource "kubernetes_service_account" "portainer" {
  metadata {
    name      = "portainer-sa"
    namespace = kubernetes_namespace.portainer.metadata[0].name
  }
}

# Portainer ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "portainer" {
  metadata {
    name = "portainer-crb"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.portainer.metadata[0].name
    namespace = kubernetes_namespace.portainer.metadata[0].name
  }
}

# Portainer Deployment
resource "kubernetes_deployment" "portainer" {
  metadata {
    name      = "portainer"
    namespace = kubernetes_namespace.portainer.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "portainer"
      }
    }

    template {
      metadata {
        labels = {
          app = "portainer"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.portainer.metadata[0].name
        
        container {
          name  = "portainer"
          image = "portainer/portainer-ce:latest"

          port {
            container_port = 9000
            name          = "http"
          }

          port {
            container_port = 8000
            name          = "edge"
          }

          volume_mount {
            name       = "portainer-data"
            mount_path = "/data"
          }
        }

        volume {
          name = "portainer-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.portainer.metadata[0].name
          }
        }
      }
    }
  }
}

# Persistent Volume for Portainer data
resource "kubernetes_persistent_volume" "portainer" {
  metadata {
    name = "portainer-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/data/portainer"
      }
    }
    storage_class_name = "standard"
  }
}

# Persistent Volume Claim for Portainer
resource "kubernetes_persistent_volume_claim" "portainer" {
  metadata {
    name      = "portainer-pvc"
    namespace = kubernetes_namespace.portainer.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "standard"
  }
}

# Portainer Service
resource "kubernetes_service" "portainer" {
  metadata {
    name      = "portainer"
    namespace = kubernetes_namespace.portainer.metadata[0].name
  }

  spec {
    selector = {
      app = "portainer"
    }

    port {
      port        = 9000
      target_port = 9000
      name        = "http"
    }

    port {
      port        = 8000
      target_port = 8000
      name        = "edge"
    }

    type = "LoadBalancer"
  }
} 