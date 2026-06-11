terraform {
  required_version = ">= 1.7.0"
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.4.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "minikube" {
  kubernetes_version = "v1.30.0"
}

provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "shop-cluster"
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand("~/.kube/config")
    config_context = "shop-cluster"
  }
}

provider "time" {}