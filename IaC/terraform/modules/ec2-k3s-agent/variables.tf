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


variable "root_volume_size" {
  type    = number
  default = 20
}

output "agent_public_ips" {
  description = "Public IP addresses of the k3s agent nodes."
  value       = aws_instance.k3s_agent[*].public_ip
}