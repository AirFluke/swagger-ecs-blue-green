variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "swiggy"
}

variable "app_name" {
  type    = string
  default = "swiggy-app"
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
  default     = 80
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

variable "image" {
  description = "Docker image repository for the application"
  type        = string
}
variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}


variable "availability_zones" {
  description = "List of availability zones"
  type = list(string)
}

variable "public_subnets" {
  description = "Map of public subnets"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
  }))
}

variable "private_subnets" {
  description = "Map of private subnets"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type = bool
  default = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type = bool
  default = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type = bool
  default = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type = bool
  default = true
}

variable "vpc_cidr" {
  description = "Swiggy Clone VPC CIDR"
  type = string
}