variable "project_name" {
  type = string
  default = "shop"
}

variable "instacne_type" {
  type = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
  description = "path to public SSH-key, ~/.ssh/shop-key.pub"
}

variable "root_volume_size" {
  type = number
  default = 20
}

variable "ssh_private_key_path" {
  type = string
  description = "path to private SSH-key"
  default = "~/.ssh/shop-key"
}

variable "kubeconfig_output_path" {
  description = "a place to save kubeconfig for AWS-cluster access"
  default = "~/.kube/shop-aws-config"
}

variable "context_name" {
  type        = string
  description = "name kubectl-context for this cluster"
  default     = "shop-aws"
}