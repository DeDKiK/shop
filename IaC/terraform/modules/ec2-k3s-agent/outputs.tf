output "agent_private_ips" {
  description = "Private IP addresses of the k3s agent nodes."
  value       = aws_instance.k3s_agent[*].private_ip
}

output "agent_ids" {
  description = "Instance IDs of the k3s agent nodes."
  value       = aws_instance.k3s_agent[*].id
}