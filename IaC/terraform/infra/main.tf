module "vpc" {
  source       = "../modules/vpc"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "security_groups" {
  source             = "../modules/security-groups"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  allowed_admin_cidr = "${var.my_ip}/32"
}

module "ec2_k3s" {
  source                 = "../modules/ec2-k3s"
  project_name           = var.project_name
  instacne_type          = var.instance_type
  subnet_id              = module.vpc.public_subnet_id
  security_group_id      = module.security_groups.security_group_id
  ssh_public_key_path    = var.ssh_public_key_path
  ssh_private_key_path   = var.ssh_private_key_path
  kubeconfig_output_path = var.kubeconfig_output_path
}

data "local_file" "node_token" {
  count = fileexists(pathexpand(module.ec2_k3s.node_token_path)) ? 1 : 0
  filename = pathexpand(module.ec2_k3s.node_token_path)
  depends_on = [ module.ec2_k3s ]
}

locals {
  k3s_token = length(data.local_file.node_token) > 0 ? trimspace(data.local_file.node_token[0].content) : ""
}

module "ec2_k3s_agent" {
  source             = "../modules/ec2-k3s-agent"
  project_name       = var.project_name
  agent_count        = var.agent_count
  instance_type      = var.agent_instance_type
  subnet_id          = module.vpc.public_subnet_id
  security_group_id  = module.security_groups.security_group_id
  key_name           = module.ec2_k3s.key_name
  server_private_ip  = module.ec2_k3s.private_ip
  k3s_token          = local.k3s_token
}