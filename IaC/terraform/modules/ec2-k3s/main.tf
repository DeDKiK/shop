# AMI

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SSH Key Pair

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

# Elastc IP

resource "aws_eip" "k3s" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-k3s-eip"
  }
}

# EC2 instance

resource "aws_instance" "k3s_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instacne_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.deployer.key_name


  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
  }

  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    public_ip = aws_eip.k3s.public_ip
  })

  tags = {
    Name = "${var.project_name}-k3s-node"
  }
}

# attachment EIP to insrance 

resource "aws_eip_association" "k3s" {
  instance_id   = aws_instance.k3s_node.id
  allocation_id = aws_eip.k3s.id
}
