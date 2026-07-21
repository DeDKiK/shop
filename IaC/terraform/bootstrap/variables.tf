variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state"
  default     = "shop-tfstate-dedkik-2026"
}

variable "lock_table_name" {
  type    = string
  default = "shop-terraform-lock"
}