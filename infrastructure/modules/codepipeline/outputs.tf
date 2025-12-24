output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.this.name
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.this.arn
}

output "role_arn" {
  description = "ARN of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline.arn
}