output "alb-dns" {
  description = "slb-dns value"
  value = aws_lb.flask-alb.dns_name
}