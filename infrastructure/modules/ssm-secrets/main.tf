resource "aws_ssm_parameter" "sonar_token" {
  name  = var.sonar_token_name
  type  = "SecureString"
  value = var.sonar_token
}

resource "aws_ssm_parameter" "docker_username" {
  name  = var.docker_username_name
  type  = "SecureString"
  value = var.docker_username
}

resource "aws_ssm_parameter" "docker_password" {
  name  = var.docker_password_name
  type  = "SecureString"
  value = var.docker_password
}


