terraform {
  required_version = "~> 1.7"

  backend "s3" {
    bucket = "shop-tfstate-dedkik-2026"
    key = "dev/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "shop-terraform-lock"
    encrypt = true
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}