output "cluster_name" {
  value       = var.cluster_name
  description = "The name of the Minikube cluster"
}

output "app_namespace" {
  value       = module.shop_app.namespace
  description = "The Kubernetes namespace for the shop application"
}

output "monitoring_namespace" {
  value       = var.monitoring_namespace
  description = "The Kubernetes namespace for monitoring tools"
}

output "access_instructions" {
  description = "Instructions for accessing services after apply."
  value       = <<-EOT

    ═══════════════════════════════════════════════════
     Services Access Instructions:
    ═══════════════════════════════════════════════════

     Shop App (through Ingress):
       minikube -p ${var.cluster_name} tunnel
       http://$(minikube -p ${var.cluster_name} ip)

     Grafana (port-forward):
       kubectl -n ${var.monitoring_namespace} port-forward \
         svc/prometheus-grafana 3000:80
       http://localhost:3000
       login: admin / <grafana_admin_password з tfvars>

     Prometheus (port-forward):
       kubectl -n ${var.monitoring_namespace} port-forward \
         svc/prometheus-kube-prometheus-prometheus 9090:9090
       http://localhost:9090

    ═══════════════════════════════════════════════════
  EOT
}
