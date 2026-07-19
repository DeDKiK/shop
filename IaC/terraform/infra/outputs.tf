output "vpc_id" {
  description = "ID of the VPC created for the infrastructure."
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet used by the k3s node."
  value       = module.vpc.public_subnet_id
}

output "instance_public_ip" {
  description = "Public IP address of the k3s control-plane instance."
  value       = module.ec2_k3s.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the k3s control-plane instance."
  value       = module.ec2_k3s.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the k3s control-plane instance."
  value       = module.ec2_k3s.ssh_command
}

output "kubeconfig_path" {
  description = "Path to the generated kubeconfig file."
  value       = module.ec2_k3s.kubeconfig_path
}

output "node_token_path" {
  description = "Path to the generated k3s node token file."
  value       = module.ec2_k3s.node_token_path
}