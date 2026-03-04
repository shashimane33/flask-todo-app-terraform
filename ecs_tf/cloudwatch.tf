# logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/flask-todo"
  retention_in_days = 7
}
