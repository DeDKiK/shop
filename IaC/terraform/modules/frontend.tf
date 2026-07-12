resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "shop-frontend"
    namespace = kubernetes_namespace.shop.metadata[0].name
    labels    = { app = "shop-frontend", managed-by = "terraform" }
  }

  spec {
    replicas = var.frontend_replicas

    selector {
      match_labels = { app = "shop-frontend" }
    }

    template {
      metadata {
        labels = { app = "shop-frontend" }
      }

      spec {

        # ── main countainer: nginx ──────────────────────────────────────
        container {
          name              = "shop-frontend"
          image             = var.frontend_image
          image_pull_policy = "Never"

          port { container_port = 80 }

          resources {
            limits   = { cpu = "300m", memory = "256Mi" }
            requests = { cpu = "50m", memory = "64Mi" }
          }


          env {
            name  = "NODE_ENV"
            value = "production"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        # ── Sidecar container: nginx-exporter ─────────────────────────────

        container {
          name  = "nginx-exporter"
          image = "nginx/nginx-prometheus-exporter:1.1.0"

          args = ["--nginx.scrape-uri=http://localhost/stub_status"]

          port {
            name           = "metrics"
            container_port = 9113
          }


          resources {
            limits   = { cpu = "50m", memory = "32Mi" }
            requests = { cpu = "10m", memory = "16Mi" }
          }


          readiness_probe {
            http_get {
              path = "/metrics"
              port = 9113
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

# ── Frontend Service ────────────────────────────────────────────────────────

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "shop-frontend-service"
    namespace = kubernetes_namespace.shop.metadata[0].name
    labels    = { app = "shop-frontend" }
  }

  spec {
    selector = { app = "shop-frontend" }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "metrics"
      port        = 9113
      target_port = 9113
    }

    type = "ClusterIP"
  }
}
