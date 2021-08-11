terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "aws_security_group" "instance" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0e66021c377d8c8b4"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "HelloTerraform"
  }
}
output "instance_public_ip" {
  description = "Public IP address"
  value       = aws_instance.app_server.public_ip
}

resource "local_file" "private_key" {
  filename        = "ec2.pem"
  file_permission = "0600"
  content         = tls_private_key.example.private_key_pem
}
