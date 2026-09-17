data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ec2_sg" {
  name = "${var.instance_name}-sg"
  description = "SG for EC2 instance"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io curl unzip jq
              systemctl enable --now docker
              usermod -aG docker ubuntu

              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -q awscliv2.zip
              ./aws/install
              rm -rf aws awscliv2.zip

              aws ssm get-parameter --region ${var.aws_region} --name "/nestjs/env" --with-decryption --query "Parameter.Value" --output text \
                | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]' > /home/ubuntu/.env.stage.prod
              chown ubuntu:ubuntu /home/ubuntu/.env.stage.prod

              cat << EOF_DEPLOY > /home/ubuntu/deploy.sh
              #!/usr/bin/env bash
              set -e

              REGION=${var.aws_region}
              ACCOUNT=${var.account_id}
              REPO=${var.ecr_repo_name}
              REGISTRY="$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
              IMAGE="$REGISTRY/$REPO:latest"

              aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY
              docker pull $IMAGE
              docker rm -f demo-app || true
              docker run -d --name demo-app --restart always -p 3000:3000 --env-file /home/ubuntu/.env.stage.prod $IMAGE
              EOF_DEPLOY

              chmod +x /home/ubuntu/deploy.sh
              chown ubuntu:ubuntu /home/ubuntu/deploy.sh
              EOF
  tags = {
    Name = var.instance_name
  }
}
