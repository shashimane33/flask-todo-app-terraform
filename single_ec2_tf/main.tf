terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# security group
resource "aws_security_group" "sg1" {
  name        = "flask-sg1"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "flask-sg1"
  }
}
# ingress 
resource "aws_vpc_security_group_ingress_rule" "backend-ig" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4   = var.cidr_all_ipv4
  from_port   = 5000
  ip_protocol = "tcp"
  to_port     = 5000
}
resource "aws_vpc_security_group_ingress_rule" "frontend-ig" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4   = var.cidr_all_ipv4
  from_port   = 3000
  ip_protocol = "tcp"
  to_port     = 3000
}
# incase of nginx
# resource "aws_vpc_security_group_ingress_rule" "http-ig" {
#   security_group_id = aws_security_group.sg1.id
#   cidr_ipv4   = var.cidr_all_ipv4
#   from_port   = 80
#   ip_protocol = "tcp"
#   to_port     = 80
# }
resource "aws_vpc_security_group_ingress_rule" "ssh-ig" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4   = var.cidr_all_ipv4
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}
# egress
resource "aws_vpc_security_group_egress_rule" "eg" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4   = var.cidr_all_ipv4
  from_port   = 0
  ip_protocol = "-1"
  to_port     = 0
}

# ec2 instance
resource "aws_instance" "myec2" {
  ami           = var.ubuntu_ami
  instance_type = "t3.micro"
  user_data = file("userdata.sh")
  key_name = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.sg1.id]

  tags = {
    Name = "flask-ec2"
  }
}