output "sonar_token_arn" {
  value = aws_ssm_parameter.sonar_token.arn
}

output "docker_username_arn" {
  value = aws_ssm_parameter.docker_username.arn
}

output "docker_password_arn" {
  value = aws_ssm_parameter.docker_password.arn
}

output "docker_registry_url_arn" {
  value = aws_ssm_parameter.docker_registry_url.arn
}
