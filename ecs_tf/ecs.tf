# cluster
resource "aws_ecs_cluster" "todo-app-cluster" {
  name = "todo-app-cluster"
}

# task definition
resource "aws_ecs_task_definition" "todo-frontend-task" {
  family                   = "todo-frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  cpu                = 512
  memory             = 1024
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "frontend-container"
      image     = var.frontend_image
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "BACKEND_URL"
          value = "http://${aws_lb.flask-alb.dns_name}:5000"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_task_definition" "todo-backend-task" {
  family                   = "todo-backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  cpu                = 512
  memory             = 1024
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "backend-container"
      image     = var.backend_image
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ecs service 
resource "aws_ecs_service" "frontend-service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.todo-app-cluster.id
  task_definition = aws_ecs_task_definition.todo-frontend-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.frontend-listener, aws_lb_listener.backend-listener]

  network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = [aws_subnet.sub1.id, aws_subnet.sub2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend-tg.arn
    container_name   = "frontend-container"
    container_port   = 3000
  }
}
resource "aws_ecs_service" "backend-service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.todo-app-cluster.id
  task_definition = aws_ecs_task_definition.todo-backend-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.backend-listener]

  network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = [aws_subnet.sub1.id, aws_subnet.sub2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend-tg.arn
    container_name   = "backend-container"
    container_port   = 5000
  }
}
