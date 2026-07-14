variable "project_name" {
  type    = string
  default = "shop"
}

variable "agent_count" {
  type        = number
  description = "number of agent-nodes"
  default     = 1
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

variable "server_private_ip" {
  type        = string
  description = "private IP server-node for joining"
}

variable "k3s_token" {
  type        = string
  description = "joining token to k3s-cluster"
  sensitive   = true
}

variable "root_volume_size" {
  type    = number
  default = 20
}