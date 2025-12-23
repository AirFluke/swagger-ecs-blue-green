variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "swiggy"
}

variable "github_repo" {
  description = "Full GitHub repository ID in the format owner/repo"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "github_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the ECS container"
  type        = number
  default     = 3000
}

variable "sonar_token" {
  type = string
}

variable "docker_username" {
  type = string
}

variable "docker_password" {
  type = string
}

variable "docker_registry_url" {
  type = string
}
