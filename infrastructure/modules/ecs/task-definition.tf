resource "aws_ecs_task_definition" "this" {
  family                   = var.project_name
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = var.image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])
}
