resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "shop-backend"
    namespace = kubernetes_namespace.shop.metadata[0].name
    labels    = { app = "shop-backend", managed-by = "terraform" }
  }

  spec {
    replicas = var.backend_replicas

    selector {
      match_labels = { app = "shop-backend" }
    }

    template {
      metadata {
        labels = { app = "shop-backend" }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.registry_credentials.metadata[0].name
        }
        container {
          name              = "shop-backend"
          image             = var.backend_image
          image_pull_policy = "IfNotPresent"

          port { container_port = 5000 }

          resources {
            limits   = { cpu = "500m", memory = "600Mi" }
            requests = { cpu = "150m", memory = "200Mi" }
          }

          # ── Environment Variables ──────────────────────────────────
          env {
            name = "MONGODB_URI"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mongo.metadata[0].name
                key  = "MONGODB_URI"
              }
            }
          }

          env {
            name  = "NODE_ENV"
            value = "production"
          }


          env {
            name  = "PORT"
            value = "5000"
          }

          # ── Probes ────────────────────────────────────────────────
          liveness_probe {
            http_get {
              path = "/api/health"
              port = 5000
            }
            initial_delay_seconds = 45
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 5000
            }
            initial_delay_seconds = 25
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

# ── Backend Service ────────────────────────────────────────────────────────
resource "kubernetes_service" "backend" {
  metadata {
    name      = "shop-backend-service"
    namespace = kubernetes_namespace.shop.metadata[0].name
    labels    = { app = "shop-backend" }
  }

  spec {
    selector = { app = "shop-backend" }

    port {
      name        = "http"
      port        = 5000
      target_port = 5000
    }

    port {
      name        = "metrics"
      port        = 9090
      target_port = 5000
    }

    type = "ClusterIP"
  }
}
