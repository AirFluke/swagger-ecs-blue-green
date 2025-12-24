resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_controller {
    type = "CODE_DEPLOY"  # Changed from "ECS" (default)
  }
  
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.project_name
    container_port   = var.container_port
  }
  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
    ]
  }

  tags = {
    Name = "${var.project_name}-${var.app_name}-service"
  }
}
