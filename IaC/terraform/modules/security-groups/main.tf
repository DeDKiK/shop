resource "aws_security_group" "k3s_node" {
  name        = "${var.project_name}-k3s-sg"
  description = "Security group for k3s single-node cluster"
  vpc_id      = var.vpc_id

  tags = {
    "Name" = "${var.project_name}-k3s-sg"
  }
}

#SSH

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_admin_cidr]
  security_group_id = aws_security_group.k3s_node.id
  description       = "SSH access (admin only)"
}


#k3s

resource "aws_security_group_rule" "k3s_api" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_admin_cidr]
  security_group_id = aws_security_group.k3s_node.id
  description       = "k3s Kubernetes API (kubectl access)"
}

# HTTP/HTTPS
resource "aws_security_group_rule" "HTTP" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s_node.id
  description       = "HTTP - public app access via Ingress"
}

resource "aws_security_group_rule" "HTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s_node.id
  description       = "HTTPS - public app access via Ingress"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s_node.id
  description       = "Allow all outbound traffic"
}