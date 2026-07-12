resource "kubernetes_ingress_v1" "shop" {
  metadata {
    name      = "shop-ingress"
    namespace = kubernetes_namespace.shop.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"          = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "60"

    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {

      http {
        path {
          path      = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.backend.metadata[0].name
              port { number = 5000 }
            }
          }
        }

        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
