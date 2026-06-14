resource "kubernetes_namespace" "shop" {
  metadata {
    name = var.namespace
    labels = {
      environment = "local"
      managed-by  = "terraform"
    }
  }
}

# ── MongoDB Secret ─────────────────────────────────────────────────────────

resource "kubernetes_secret" "mongo" {
  metadata {
    name      = "mongo-secret"
    namespace = kubernetes_namespace.shop.metadata[0].name
  }
  type = "Opaque"

  data = {
    MONGODB_URI = var.mongo_uri
  }
}
