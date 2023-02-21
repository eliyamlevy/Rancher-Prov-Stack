#UPSTREAM
resource "aws_instance" "local-node" {
  count                  = var.node_count
  instance_type          = "t3.large"
  ami                    = "ami-0066d036f9777ec38"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  user_data = <<EOF
#!/bin/bash -x

export DEBIAN_FRONTEND=noninteractive
curl -sL https://releases.rancher.com/install-docker/20.10.sh | sh
sudo usermod -aG docker ubuntu
EOF

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "${var.aws_prefix}-${count.index}"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
