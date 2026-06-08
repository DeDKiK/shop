resource "kubernetes_namespace" "shop-app" {
  metadata {
    name = "shop"
  }
}

#=================== BACKEND ===================

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "shop-backend"
    namespace = kubernetes_namespace.shop-app.metadata[0].name
    labels = {
      app = "shop-backend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "shop-backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "shop-backend"
        }
      }

      spec {
        container {
            name  = "shop-backend"
            image             = "shop-backend:latest"
            image_pull_policy = "Never"

          port {
            container_port = 5000
          }
          #Probes
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

            resources {
              limits = {
                cpu    = "500m"
                memory = "600Mi"
              }
              requests = {
                cpu    = "150m"
                memory = "200Mi"
              }
            }

            env {
                name = "MONGODB_URI"
                value = "mongodb://mongo-service:27017/shop"
            }

            env {
                name = "NODE_ENV"
                value = "production"
            }
        }
      }
    }
  }
}
#=================== BACKEND SERVICE ===================
resource "kubernetes_service" "backend" {
    metadata{
        name = "shop-backend-service"
        namespace = kubernetes_namespace.shop-app.metadata[0].name
    }
    spec{
        selector = {
            app = "shop-backend"
        }
        port {
            port = 5000
            target_port = 5000
        }
        type = "ClusterIP"
    }
}

#=================== FRONTEND ===================

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "shop-frontend"
    namespace = kubernetes_namespace.shop-app.metadata[0].name
    labels = {
      app = "shop-frontend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "shop-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "shop-frontend"
        }
      }

      spec {
        container {
            name  = "shop-frontend"
            image             = "shop-frontend:latest"
            image_pull_policy = "Never"
          port {
            container_port = 80
          }
          #Probes
            liveness_probe {
              http_get {
                path = "/health"
                port = 80
              }
                initial_delay_seconds = 45
                period_seconds        = 10
                timeout_seconds       = 5
                failure_threshold     = 3
            }

            readiness_probe {
              http_get {
                path = "/health"
                port = 80
              }
                initial_delay_seconds = 25
                period_seconds        = 5
                timeout_seconds       = 3
                failure_threshold     = 3
            }

            resources {
              limits = {
                cpu    = "300m"
                memory = "256Mi"
              }
              requests = {
                cpu    = "50m"
                memory = "64Mi"
              }
            }

            env {
                name = "BACKEND_URL"
                value = "http://shop-backend-service:5000"
            }

            env {
                name = "NODE_ENV"
                value = "production"
            }
        }
      }
    }
  }
}
#=================== FRONTEND SERVICE ===================
resource "kubernetes_service" "frontend" {
    metadata{
        name = "shop-frontend-service"
        namespace = kubernetes_namespace.shop-app.metadata[0].name
    }
    spec{
        selector = {
            app = "shop-frontend"
        }
        port {
            port = 80
            target_port = 80
        }
        type = "ClusterIP"
    }
}


#=================== MONGO DB ===================
resource "kubernetes_deployment" "mongo" {
    metadata {
        name = "mongo"
        namespace = kubernetes_namespace.shop-app.metadata[0].name
        labels = {
            app = "mongo"
        }
    }
    spec {
        replicas = 1

        selector {
            match_labels = {
                app = "mongo"
            }
        }

        template {
            metadata {
                labels = {
                    app = "mongo"
                }
            }

            spec {
                container {
                    name  = "mongo"
                    image = "mongo:7.0"

                    port {
                        container_port = 27017
                    }
                    resources {
                        limits = {
                            cpu    = "500m"
                            memory = "512Mi"
                        }
                        requests = {
                            cpu    = "200m"
                            memory = "256Mi"
                        }
                    }

                    readiness_probe {
                      tcp_socket {
                        port = 27017
                      }
                      initial_delay_seconds = 10
                      period_seconds = 5
                    }
                }
            }
        }
    }
}

#=================== MONGO SERVICE ===================
resource "kubernetes_service" "mongo" {
    metadata{
        name = "mongo-service"
        namespace = kubernetes_namespace.shop-app.metadata[0].name
    }
    spec{
        selector = {
            app = "mongo"
        }
        port {
            port = 27017
            target_port = 27017  
        }
        type = "ClusterIP"
    }
}

#=================== INGRESS ===================
resource "kubernetes_ingress_v1" "shop-ingress" { 
    metadata {
        name = "shop-ingress"
        namespace = kubernetes_namespace.shop-app.metadata[0].name
        annotations = {
            # "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "nginx.ingress.kubernetes.io/use-regex" = "true"
            "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
        }
    }

    spec {
        ingress_class_name = "nginx"

        rule {
            http {
                # Backend route
                path {
                    path = "/api"
                    path_type = "Prefix"
                    backend {
                        service {
                            name = kubernetes_service.backend.metadata[0].name
                            port {
                                number = 5000
                            }
                        }
                    }
                }
                # Frontend route
                path {
                    path = "/"
                    path_type = "Prefix"
                    backend {
                        service {
                            name = kubernetes_service.frontend.metadata[0].name
                            port {
                                number = 80
                            }
                        }
                    }
                }
            }
        }
    }
}