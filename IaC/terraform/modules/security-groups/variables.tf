variable "project_name" {
  type    = string
  default = "shop"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the security group in"
}

variable "allowed_admin_cidr" {
  type        = string
  description = "CIDR (your IP/32) for SSH and k3s API access"
}