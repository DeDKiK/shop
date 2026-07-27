variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "shop"
}

variable "my_ip" {
  type        = string
  description = "Your public IP for SSH/k3s API access (without /32)"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ssh_public_key_path" {
  type        = string
  description = "path to public SSH-key"
  default     = "~/.ssh/shop-key.pub"
}

variable "ssh_private_key_path" {
  type        = string
  description = "path to private SSH-key"
  default     = "~/.ssh/shop-key"
}

variable "kubeconfig_output_path" {
  description = "a place to save kubeconfig for AWS-cluster access"
  default     = "~/.kube/shop-aws-config"
}

variable "agent_count" {
  type    = number
  default = 1
}

variable "agent_instance_type" {
  type    = string
  default = "t3.small"
}

variable "runner_instance_type" {
  type = string
  default = "t3.small"
}