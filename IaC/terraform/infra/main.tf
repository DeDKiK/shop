module "vpc" {
  source = "../modules/vpc"
  project_name = var.project_name
  aws_region = var.aws_region
}

module "security_groups" {
  source = "../modules/security-groups"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  allowed_admin_cidr = "${var.my_ip}/32"
}