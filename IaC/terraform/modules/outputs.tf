
output "namespace" {
  value = kubernetes_namespace.shop.metadata[0].name
}

output "backend_service_name" {
  value = kubernetes_service.backend.metadata[0].name
}

output "frontend_service_name" {
  value = kubernetes_service.frontend.metadata[0].name
}

output "mongo_pvc_name" {
  value = kubernetes_persistent_volume_claim.mongo.metadata[0].name
}
