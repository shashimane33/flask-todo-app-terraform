# alb-sg
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow 80 & 5000 on alb"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "alb-ig-80" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = var.cidr_all_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "alb-ig-5000" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = var.cidr_all_ipv4
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}
resource "aws_vpc_security_group_egress_rule" "alb-eg" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = var.cidr_all_ipv4
  ip_protocol       = "-1" 
}
# ecs-sg
resource "aws_security_group" "ecs-sg" {
  name        = "ecs-sg"
  description = "Allow 3000 & 5000 on ecs"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ecs-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "ecs-ig-3000" {
  security_group_id = aws_security_group.ecs-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}
resource "aws_vpc_security_group_ingress_rule" "ecs-ig-5000" {
  security_group_id = aws_security_group.ecs-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}
resource "aws_vpc_security_group_egress_rule" "ecs-eg" {
  security_group_id = aws_security_group.ecs-sg.id
  cidr_ipv4         = var.cidr_all_ipv4
  ip_protocol       = "-1" 
}