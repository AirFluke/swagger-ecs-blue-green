resource "aws_codedeploy_app" "ecs" {
  name             = "{var.project_name}-ecs-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs" {
  app_name               = aws_codedeploy_app.ecs.name
  deployment_group_name  = "swiggy-blue-green"
  codedeploy_role_arn       = var.codedeploy_role_arn

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = var.blue_tg_name
      }
      target_group {
        name = var.green_tg_name
      }

      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
}
