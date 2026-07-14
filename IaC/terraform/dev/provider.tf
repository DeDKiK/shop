
provider "kubernetes" {
  config_path    = pathexpand("~/.kube/shop-aws-config")
  config_context = var.cluster_name
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand("~/.kube/shop-aws-config")
    config_context = var.cluster_name
  }
}