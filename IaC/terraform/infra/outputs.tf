output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "instance_public_ip" {
  value = module.ec2_k3s.public_ip
}

output "ssh_command" {
  value = module.ec2_k3s.ssh_command
}