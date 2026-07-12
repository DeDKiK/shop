
# ── PersistentVolumeClaim ──────────────────────────────────────────────────
resource "kubernetes_persistent_volume_claim" "mongo" {
  metadata {
    name      = "mongo-pvc"
    namespace = kubernetes_namespace.shop.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = { storage = var.mongo_storage_size }
    }
  }
  wait_until_bound = true
}

# ── MongoDB Deployment ─────────────────────────────────────────────────────

resource "kubernetes_deployment" "mongo" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace.shop.metadata[0].name
    labels    = { app = "mongo", managed-by = "terraform" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "mongo" }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = { app = "mongo" }
      }

      spec {
        container {
          name  = "mongo"
          image = "mongo:7.0"

          port { container_port = 27017 }

          resources {
            limits   = { cpu = "500m", memory = "512Mi" }
            requests = { cpu = "200m", memory = "256Mi" }
          }
          volume_mount {
            name       = "mongo-data"
            mount_path = "/data/db"
          }
          liveness_probe {
            exec {
              command = ["mongosh", "--eval", "db.adminCommand('ping')"]
            }
            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 10
            failure_threshold     = 3
          }

          readiness_probe {
            tcp_socket { port = 27017 }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "mongo-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mongo.metadata[0].name
          }
        }
      }
    }
  }
}

# ── MongoDB Service ────────────────────────────────────────────────────────

resource "kubernetes_service" "mongo" {
  metadata {
    name      = "mongo-service"
    namespace = kubernetes_namespace.shop.metadata[0].name
  }

  spec {
    selector = { app = "mongo" }
    port {
      port        = 27017
      target_port = 27017
    }
    type = "ClusterIP"
  }
}
