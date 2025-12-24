output "project_name" {
  value = aws_codebuild_project.this.name
}

output "project_arn" {
  value = aws_codebuild_project.this.arn
}

output "role_arn" {
  description = "ARN of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild.arn
}