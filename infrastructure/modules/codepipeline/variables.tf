variable "project_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "codestar_connection_arn" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

variable "codebuild_project" {
  type = string
}

variable "codedeploy_app" {
  type = string
}

variable "codedeploy_group" {
  type = string
}

variable "artifact_bucket_name" {
  type = string
}

variable "artifact_bucket_arn" {
  description = "ARN of the S3 bucket for artifacts"
  type        = string
}
variable "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  type        = string
}