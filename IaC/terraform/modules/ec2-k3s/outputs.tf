output "instance_id" {
  value = aws_instance.k3s_node.id
}

output "public_ip" {
  value = aws_eip.k3s.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/shop-key ubuntu@${aws_eip.k3s.public_ip}"
}

output "kubeconfig_path" {
  value = var.kubeconfig_output_path
}

output "key_name" {
  value = aws_key_pair.deployer.key_name
}

output "private_ip" {
  value = aws_instance.k3s_node.private_ip
}

output "node_token_path" {
  value = var.node_token_output_path
}