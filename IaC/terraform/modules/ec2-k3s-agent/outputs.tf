output "agent_private_ips" {
  value = aws_instance.k3s_agent[*].private_ip
}

output "agent_ids" {
  value = aws_instance.k3s_agent[*].id
}