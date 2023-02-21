# Get latest Ubuntu Linux Focal Fossa 20.04 AMI
data "aws_ami" "ubuntu-linux-2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# print the instance info
output "instance_public_ip" {
  value = [for instance in aws_instance.local-node : instance.public_ip]
}
output "instance_private_ip" {
  value = [for instance in aws_instance.local-node : instance.private_ip]
}

# print cluster.yml
output "cluster_yml" { 
  value = templatefile("cluster.yml.tpl",
    {
      ssh_private_key_path = var.ssh_private_key_path
      instance1_ext = aws_instance.local-node[0].public_ip
      instance1_int = aws_instance.local-node[0].private_ip
      instance2_ext = aws_instance.local-node[1].public_ip
      instance2_int = aws_instance.local-node[1].private_ip
      instance3_ext = aws_instance.local-node[2].public_ip
      instance3_int = aws_instance.local-node[2].private_ip
    })
}

# create cluster.yml
resource "local_file" "rke-config" {
  content = templatefile("cluster.yml.tpl",
    {
      
      ssh_private_key_path = var.ssh_private_key_path
      instance1_ext = aws_instance.local-node[0].public_ip
      instance1_int = aws_instance.local-node[0].private_ip
      instance2_ext = aws_instance.local-node[1].public_ip
      instance2_int = aws_instance.local-node[1].private_ip
      instance3_ext = aws_instance.local-node[2].public_ip
      instance3_int = aws_instance.local-node[2].private_ip
    })
    filename = "tf-rke-config.yaml"
}
