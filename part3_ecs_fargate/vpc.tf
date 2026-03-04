# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# subnets
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub1"
  }
}
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub2"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.cidr_all_ipv4
    gateway_id = aws_internet_gateway.igw.id
  }
}
# route table association
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}