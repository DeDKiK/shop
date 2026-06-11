resource "helm_release" "prometheus_stack" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "65.1.1"

  depends_on = [time_sleep.wait_for_cluster]

  set {
    name  = "grafana.adminPassword"
    value = "admin123"
  }

  set {
    name  = "grafana.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "prometheus.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  set {
  name  = "grafana.sidecar.dashboards.enabled"
  value = "true"
}

set {
  name  = "grafana.sidecar.dashboards.label"
  value = "grafana_dashboard"
}
}

resource "kubernetes_manifest" "frontend_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "shop-frontend-service-monitor"
      namespace = "monitoring"
      labels = {
        release = helm_release.prometheus_stack.name
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = ["shop"]
      }
      selector = {
        matchLabels = {
          app = "shop-frontend"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "15s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "backend_service_monitor" {
    manifest = {
        apiVersion = "monitoring.coreos.com/v1"
        kind       = "ServiceMonitor"
        metadata = {
            name      = "shop-backend-service-monitor"
            namespace = "monitoring"
            labels = {
                release = helm_release.prometheus_stack.name
            }
        }
        spec = {
            namespaceSelector = {
                matchNames = ["shop"]
            }
            selector = {
                matchLabels = {
                    app = "shop-backend"
                }
            }
            endpoints = [
                {
                    port     = "metrics"
                    path     = "/metrics"
                    interval = "15s"
                }
            ]
        }
    }
}

resource "kubernetes_config_map" "grafana_dashboard" {
  metadata {
    name      = "shop-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "shop-dashboard.json" = jsonencode({
      title       = "Shop Application"
      uid         = "shop-app"
      schemaVersion = 27
      panels = [
        {
          id    = 1
          title = "HTTP Requests Rate"
          type  = "graph"
          gridPos = { x = 0, y = 0, w = 12, h = 8 }
          targets = [{
            expr         = "rate(shop_backend_http_requests_total[5m])"
            legendFormat = "{{method}} {{route}} {{status_code}}"
          }]
        },
        {
          id    = 2
          title = "Request Duration (p95)"
          type  = "graph"
          gridPos = { x = 12, y = 0, w = 12, h = 8 }
          targets = [{
            expr         = "histogram_quantile(0.95, rate(shop_backend_http_request_duration_seconds_bucket[5m]))"
            legendFormat = "p95 {{route}}"
          }]
        },
        {
          id    = 3
          title = "Node.js Heap Used"
          type  = "graph"
          gridPos = { x = 0, y = 8, w = 12, h = 8 }
          targets = [{
            expr         = "shop_backend_nodejs_heap_size_used_bytes"
            legendFormat = "{{pod}}"
          }]
        },
        {
          id    = 4
          title = "Active HTTP Connections (nginx)"
          type  = "graph"
          gridPos = { x = 12, y = 8, w = 12, h = 8 }
          targets = [{
            expr         = "nginx_connections_active"
            legendFormat = "{{pod}}"
          }]
        },
        {
          id    = 5
          title = "nginx Requests Total"
          type  = "graph"
          gridPos = { x = 0, y = 16, w = 12, h = 8 }
          targets = [{
            expr         = "rate(nginx_http_requests_total[5m])"
            legendFormat = "{{pod}}"
          }]
        },
        {
          id    = 6
          title = "Pod Restarts"
          type  = "graph"
          gridPos = { x = 12, y = 16, w = 12, h = 8 }
          targets = [{
            expr         = "kube_pod_container_status_restarts_total{namespace=\"shop\"}"
            legendFormat = "{{pod}}"
          }]
        }
      ]
    })
  }
}