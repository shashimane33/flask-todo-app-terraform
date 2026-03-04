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

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "myvpc"
  }
}

# Create subnet
resource "aws_subnet" "sub-frontend" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub-frontend"
  }
}
resource "aws_subnet" "sub-backend" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub-backend"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}
# route table
resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = var.cidr_all_ipv4
    gateway_id = aws_internet_gateway.igw.id
  }
}
# route table association
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub-frontend.id
  route_table_id = aws_route_table.myrt.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub-backend.id
  route_table_id = aws_route_table.myrt.id
}

# security group
resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "sg1"
  }
}
# ingress - egress
resource "aws_vpc_security_group_ingress_rule" "frontend-ig" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4         = var.cidr_all_ipv4
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}
resource "aws_vpc_security_group_ingress_rule" "backend-ig" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4         = var.cidr_all_ipv4
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}
resource "aws_vpc_security_group_ingress_rule" "ssh-ig" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4         = var.cidr_all_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "eg" {
  security_group_id = aws_security_group.sg1.id
  cidr_ipv4         = var.cidr_all_ipv4
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

# ec2
resource "aws_instance" "backend-server" {
  ami                    = var.ubuntu_ami
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg1.id]
  subnet_id              = aws_subnet.sub-backend.id
  key_name               = var.key_pair_name
  user_data              = file("backend_setup.sh")

  tags = {
    Name = "backend-server"
  }
}
resource "aws_instance" "frontend-server" {
  ami                    = var.ubuntu_ami
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg1.id]
  subnet_id              = aws_subnet.sub-frontend.id
  key_name               = var.key_pair_name
  user_data = templatefile("frontend_setup.sh", {
    backend_ip = aws_instance.backend-server.public_ip
  })
  depends_on = [aws_instance.backend-server]

  tags = {
    Name = "frontend-server"
  }
}
