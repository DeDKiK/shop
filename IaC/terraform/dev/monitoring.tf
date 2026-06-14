resource "kubernetes_manifest" "frontend_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "shop-frontend-service-monitor"
      namespace = var.monitoring_namespace
      labels = {
        release = helm_release.prometheus_stack.name  
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = [var.namespace]
      }
      selector = {
        matchLabels = {
          app = "shop-frontend"
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

  depends_on = [helm_release.prometheus_stack]  
}

resource "kubernetes_manifest" "backend_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "shop-backend-service-monitor"
      namespace = var.monitoring_namespace
      labels = {
        release = helm_release.prometheus_stack.name  
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = [var.namespace]
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

  depends_on = [helm_release.prometheus_stack]  
}

resource "kubernetes_config_map" "grafana_dashboard" {
  metadata {
    name      = "shop-dashboard"
    namespace = var.monitoring_namespace
    labels = {
      grafana_dashboard = "1"
    }
  }

  depends_on = [helm_release.prometheus_stack]  

  data = {
    "shop-dashboard.json" = jsonencode({
      title         = "Shop Application"
      uid           = "shop-app-v1"
      schemaVersion = 38

      panels = [
        {
          id      = 1
          title   = "HTTP Requests Rate (backend)"
          type    = "timeseries"
          gridPos = { x = 0, y = 0, w = 12, h = 8 }
          targets = [{
            datasource   = { type = "prometheus", uid = "prometheus" }
            expr         = "rate(shop_backend_http_requests_total[5m])"
            legendFormat = "{{method}} {{route}} {{status_code}}"
          }]
          fieldConfig = {
            defaults = { unit = "reqps" }
          }
        },
        {
          id      = 2
          title   = "Request Duration p95 (backend)"
          type    = "timeseries"
          gridPos = { x = 12, y = 0, w = 12, h = 8 }
          targets = [{
            datasource   = { type = "prometheus", uid = "prometheus" }
            expr         = "histogram_quantile(0.95, rate(shop_backend_http_request_duration_seconds_bucket[5m]))"
            legendFormat = "p95 {{route}}"
          }]
          fieldConfig = {
            defaults = { unit = "s" }
          }
        },
        {
          id      = 3
          title   = "Node.js Heap Used"
          type    = "timeseries"
          gridPos = { x = 0, y = 8, w = 12, h = 8 }
          targets = [{
            datasource   = { type = "prometheus", uid = "prometheus" }
            expr         = "shop_backend_nodejs_heap_size_used_bytes"
            legendFormat = "{{pod}}"
          }]
          fieldConfig = {
            defaults = { unit = "bytes" }
          }
        },
        {
          id      = 4
          title   = "nginx Active Connections (frontend)"
          type    = "timeseries"
          gridPos = { x = 12, y = 8, w = 12, h = 8 }
          targets = [{
            datasource   = { type = "prometheus", uid = "prometheus" }
            expr         = "nginx_connections_active"
            legendFormat = "{{pod}}"
          }]
        },
        {
          id      = 5
          title   = "nginx Requests Rate (frontend)"
          type    = "timeseries"
          gridPos = { x = 0, y = 16, w = 12, h = 8 }
          targets = [{
            datasource   = { type = "prometheus", uid = "prometheus" }
            expr         = "rate(nginx_http_requests_total[5m])"
            legendFormat = "{{pod}}"
          }]
          fieldConfig = {
            defaults = { unit = "reqps" }
          }
        },
        {
          id      = 6
          title   = "Pod Restarts (namespace: shop)"
          type    = "timeseries"
          gridPos = { x = 12, y = 16, w = 12, h = 8 }
          targets = [{
            datasource   = { type = "prometheus", uid = "prometheus" }
            expr         = "kube_pod_container_status_restarts_total{namespace=\"${var.namespace}\"}"
            legendFormat = "{{pod}} / {{container}}"
          }]
        }
      ]
    })
  }
}