output "instance_id" {
  description = "ID of the EC2 instance running k3s."
  value       = aws_instance.k3s_node.id
}

output "public_ip" {
  description = "Public IP address of the k3s node."
  value       = aws_eip.k3s.public_ip
}

output "private_ip" {
  description = "Private IP address of the k3s node."
  value       = aws_instance.k3s_node.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the k3s node."
  value       = "ssh -i ${pathexpand(var.ssh_private_key_path)} ubuntu@${aws_eip.k3s.public_ip}"
}

output "kubeconfig_path" {
  description = "Path to the generated kubeconfig file."
  value       = var.kubeconfig_output_path
}

output "key_name" {
  description = "Name of the AWS key pair used for the instance."
  value       = aws_key_pair.deployer.key_name
}

output "node_token_path" {
  description = "Path to the file containing the k3s node token."
  value       = var.node_token_output_path
}