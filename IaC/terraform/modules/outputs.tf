
output "namespace" {
  description = "Kubernetes namespace created for the shop application."
  value       = kubernetes_namespace.shop.metadata[0].name
}

output "backend_service_name" {
  description = "Name of the backend Kubernetes service."
  value       = kubernetes_service.backend.metadata[0].name
}

output "frontend_service_name" {
  description = "Name of the frontend Kubernetes service."
  value       = kubernetes_service.frontend.metadata[0].name
}

output "ingress_name" {
  description = "Name of the ingress resource for the shop application."
  value       = kubernetes_ingress_v1.shop.metadata[0].name
}

output "mongo_pvc_name" {
  description = "Name of the persistent volume claim used by MongoDB."
  value       = kubernetes_persistent_volume_claim.mongo.metadata[0].name
}

output "mongo_secret_name" {
  description = "Name of the Kubernetes secret containing the MongoDB connection string."
  value       = kubernetes_secret.mongo.metadata[0].name
}
