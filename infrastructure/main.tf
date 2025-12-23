provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "swiggy-terraform-state"
    key    = "ecs-blue-green/terraform.tfstate"
    region = "us-east-1"
  }
}


# VPC and Networking Layer
module "vpc" {
  source = "./modules/vpc"
}


# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  subnets        = module.vpc.public_subnets
  container_port = var.container_port
}


# ECS Cluster and Services
module "ecs" {
  source = "./modules/ecs"

  project_name   = var.project_name
  image          = "docker.io/your-docker-username/swiggy:latest"
  container_port = var.container_port

  blue_tg        = module.alb.blue_target_group_arn
  green_tg       = module.alb.green_target_group_arn
}


# IAM Roles for CI CD
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}


# AWS CodeBuild Project
module "codebuild" {
  source = "./modules/codebuild"

  project_name      = var.project_name
  github_repo       = var.github_repo
  service_role_arn = module.iam.codebuild_role_arn
}


# AWS CodeDeploy for ECS
module "codedeploy" {
  source = "./modules/codedeploy"

  project_name           = var.project_name
  cluster_name           = module.ecs.cluster_name
  service_name           = module.ecs.service_name
  listener_arn           = module.alb.listener_arn
  blue_tg_name           = module.alb.blue_target_group_name
  green_tg_name          = module.alb.green_target_group_name
  codedeploy_role_arn    = module.iam.codedeploy_role_arn
}


# AWS CodePipeline

module "codepipeline" {
  source = "./modules/codepipeline"

  project_name         = var.project_name
  github_repo          = var.github_repo
  github_branch        = var.github_branch
  connection_arn       = var.github_connection_arn

  codebuild_project    = module.codebuild.project_name
  codedeploy_app       = module.codedeploy.app_name
  codedeploy_group     = module.codedeploy.deployment_group_name

  pipeline_role_arn    = module.iam.codepipeline_role_arn
}


module "ssm_secrets" {
  source = "./modules/ssm-secrets"

  sonar_token_name        = "/cicd/sonar/sonar-token"
  sonar_token             = var.sonar_token

  docker_username_name    = "/cicd/docker-credentials/username"
  docker_username         = var.docker_username

  docker_password_name    = "/cicd/docker-credentials/password"
  docker_password         = var.docker_password

  docker_registry_url_name = "/cicd/docker-registry/url"
  docker_registry_url      = var.docker_registry_url
}
