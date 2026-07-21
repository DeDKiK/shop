output "cluster_name" {
  description = "The name of the local Kubernetes cluster."
  value       = var.cluster_name
}

output "app_namespace" {
  description = "The Kubernetes namespace for the shop application."
  value       = module.shop_app.namespace
}

output "monitoring_namespace" {
  description = "The Kubernetes namespace for monitoring tools."
  value       = var.monitoring_namespace
}

output "access_instructions" {
  description = "Instructions for accessing services after apply."
  value       = <<-EOT

    ═══════════════════════════════════════════════════
     Services Access Instructions:
    ═══════════════════════════════════════════════════

     Shop App (through Ingress, public IP):
       http://${data.terraform_remote_state.infra.outputs.instance_public_ip}

     Grafana (port-forward):
       kubectl -n ${var.monitoring_namespace} port-forward \
         svc/prometheus-grafana 3000:80
       http://localhost:3000
       login: admin / <value of grafana_admin_password from tfvars>

     Prometheus (port-forward):
       kubectl -n ${var.monitoring_namespace} port-forward \
         svc/prometheus-kube-prometheus-prometheus 9090:9090
       http://localhost:9090

    ═══════════════════════════════════════════════════
  EOT
}