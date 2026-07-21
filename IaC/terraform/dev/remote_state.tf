data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "shop-tfstate-dedkik-2026"
    key    = "infra/terraform.tfstate"
    region = "eu-central-1"
  }
}