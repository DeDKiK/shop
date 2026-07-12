

module "shop_app" {
  source = "../modules"

  namespace          = var.namespace
  backend_image      = var.backend_image
  frontend_image     = var.frontend_image
  backend_replicas   = var.backend_replicas
  frontend_replicas  = var.frontend_replicas
  mongo_uri          = var.mongo_uri
  mongo_storage_size = var.mongo_storage_size


}

resource "helm_release" "prometheus_stack" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.monitoring_namespace
  create_namespace = true
  version          = var.prometheus_chart_version

  timeout = 600

  wait = true



  values = [
    yamlencode({
      grafana = {
        adminPassword = var.grafana_admin_password
        service       = { type = "ClusterIP" }
        sidecar = {
          dashboards = {
            enabled = true
            label   = "grafana_dashboard"
          }
        }
      }
      prometheus = {
        service = { type = "ClusterIP" }
        prometheusSpec = {
          serviceMonitorSelectorNilUsesHelmValues = false
          serviceMonitorSelector                  = {}
        }
      }
      alertmanager = {
        enabled = false
      }
    })
  ]

}



