provider "kubernetes" {
  config_path = pathexpand("~/.kube/shop-aws-config")
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/shop-aws-config")
  }
}