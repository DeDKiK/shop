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


# ── GitLab Container Registry pull secret ───────────────────────────────────

resource "kubernetes_secret" "registry_credentials" {
  metadata {
    name      = "gitlab-registry-credentials"
    namespace = kubernetes_namespace.shop.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.registry_server) = {
          username = var.registry_username
          password = var.registry_password
          auth     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
}