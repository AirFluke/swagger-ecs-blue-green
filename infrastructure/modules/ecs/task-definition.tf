# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.app_name}-logs"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.project_name
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = "${var.image}:latest"
       cpu       = 256
        memory    = 512
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    }
  ])
  tags = {
    Name = "${var.project_name}-${var.app_name}-task"
  }
}
