# AMI

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = [ "099720109477" ]

  filter {
    name = "name"
    values = [ "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" ]
  }

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

# SSH Key Pair

resource "aws_key_pair" "deployer" {
  key_name = "${var.project_name}-key"
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
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instacne_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [ var.security_group_id ]
  key_name = aws_key_pair.deployer.key_name


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
  instance_id = aws_instance.k3s_node.id
  allocation_id = aws_eip.k3s.id
}

# automatic retrieval kubeconfig after installing k3s

resource "null_resource" "fetch_kubeconfig" {
  triggers = {
    instance_id = aws_instance.k3s_node.id
  }

  depends_on = [ aws_eip_association.k3s ]

  connection {
    type = "ssh"
    host = aws_eip.k3s.public_ip
    user = "ubuntu"
    private_key = file(pathexpand(var.ssh_private_key_path))
    timeout = "3m"
  }

  provisioner "remote-exec"{
    inline = [
      "i=0; until sudo test -f /var/log/k3s-install-done.log || [ $i -ge 30 ]; do i=$((i+1)); sleep 10; done",
      "sudo test -f /var/log/k3s-install-done.log || (echo 'k3s install timed out after 5 minutes' && exit 1)",
    ]
  }


  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p $(dirname ${var.kubeconfig_output_path})
      scp -o StrictHostKeyChecking=no -i ${pathexpand(var.ssh_private_key_path)} ubuntu@${aws_eip.k3s.public_ip}:/etc/rancher/k3s/k3s.yaml ${var.kubeconfig_output_path}
      sed -i "s/127.0.0.1/${aws_eip.k3s.public_ip}/" ${var.kubeconfig_output_path}
      sed -i "s/: default$/: ${var.context_name}/" ${var.kubeconfig_output_path}
      chmod 600 ${var.kubeconfig_output_path}
      echo "kubeconfig saved: ${var.kubeconfig_output_path} (context: ${var.context_name})"
    EOT
    interpreter = ["bash", "-c"]
  }
}

