output "app_name" {
  value = aws_codedeploy_app.ecs.name
}

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.ecs.deployment_group_name
}

output "app_arn" {
  value = aws_codedeploy_app.ecs.arn
}
