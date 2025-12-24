variable "project_name" {
  type = string
}

variable "image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "target_group_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS instances"
  type        = list(string)
}

variable "ecs_instance_profile_name" {
  description = "Name of the IAM instance profile for ECS instances"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}