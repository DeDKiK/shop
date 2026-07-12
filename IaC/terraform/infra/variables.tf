variable "aws_region" {
  type = string
  default = "eu-central-1"
}

variable "project_name" {
  type = string
  default = "shop"
}

variable "my_ip" {
  type = string
  description = "Your public IP for SSH/k3s API access (without /32)"
}