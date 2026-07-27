variable "project_name" {
  type    = string
  default = "shop"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "key_name" {
  type        = string
  description = "name of existing SSH key pair (from server-module)"
}

variable "root_volume_size" {
  type    = number
  default = 20
}