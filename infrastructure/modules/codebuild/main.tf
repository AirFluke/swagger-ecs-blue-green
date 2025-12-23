resource "aws_codebuild_project" "this" {
  name = var.project_name

  source {
    type      = "GITHUB"
    location  = var.github_repo
    buildspec = "buildspec.yaml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }

  service_role_arn = var.role_arn
}
