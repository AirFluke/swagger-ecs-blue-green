variable "project_name" {
  type = string
}


variable "role_arn" {
  type = string
}

variable "artifact_bucket_arn" {
  description = "ARN of the S3 bucket for artifacts"
  type        = string
}

