# target group
resource "aws_lb_target_group" "frontend-tg" {
  name        = "frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    path = "/"
  }
}
resource "aws_lb_target_group" "backend-tg" {
  name        = "backend-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    path = "/task"
  }
}

# alb
resource "aws_lb" "flask-alb" {
  name               = "flask-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
}

# alb listener
resource "aws_lb_listener" "frontend-listener" {
  load_balancer_arn = aws_lb.flask-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend-tg.arn
  }
}
resource "aws_lb_listener" "backend-listener" {
  load_balancer_arn = aws_lb.flask-alb.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend-tg.arn
  }
}