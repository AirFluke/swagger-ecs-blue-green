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

  region               = var.aws_region
  vpc_cidr            = var.vpc_cidr
  project_name        = var.project_name
  availability_zones  = var.availability_zones
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
}


# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port = var.container_port

  depends_on = [module.vpc]
}


# ECS Cluster and Services
module "ecs" {
  source = "./modules/ecs"
  
  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  ecs_instance_profile_name  = module.iam.ecs_instance_profile_name
  alb_security_group_id      = module.alb.security_group_id
  target_group_arn           = module.alb.blue_target_group_arn
  key_pair_name              = var.key_pair_name
  app_name                   = var.app_name
  image                       =  var.image
  aws_region                 = var.aws_region
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  container_port = var.container_port
  
  depends_on = [module.vpc, module.iam, module.alb]
}



# IAM Roles and Policies
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name 
}

# AWS CodeDeploy for ECS
module "codedeploy" {
  source = "./modules/codedeploy"

  project_name           = var.project_name
  cluster_name = "${var.project_name}-cluster"
  service_name = "${var.project_name}-service"
  listener_arn           = module.alb.listener_arn
  blue_tg_name           = module.alb.blue_target_group_name
  green_tg_name          = module.alb.green_target_group_name
  codedeploy_role_arn    = module.iam.codedeploy_role_arn

  depends_on = [ module.alb,module.ecs, module.iam]
}

# AWS CodePipeline

module "codepipeline" {
  source = "./modules/codepipeline"

  project_name         = var.project_name
  github_repo          = var.github_repo
  github_branch        = var.github_branch
  role_arn = module.codepipeline.role_arn
  codebuild_project    = module.codebuild.project_name
  codedeploy_app       = module.codedeploy.app_name
  codedeploy_group     = module.codedeploy.deployment_group_name
  codestar_connection_arn         = var.github_connection_arn
  artifact_bucket_name            = module.s3.bucket_name
  artifact_bucket_arn             = module.s3.bucket_arn
  codebuild_project_arn             = module.codebuild.project_arn
}

# AWS S3 Bucket for Artifacts
module "s3" {
  source = "./modules/s3"
  project_name = var.project_name
}

# AWS CodeBuild Project
module "codebuild" {
  source = "./modules/codebuild"

  project_name      = var.project_name
  role_arn = module.codebuild.role_arn
    artifact_bucket_arn = module.s3.bucket_arn

  depends_on = [module.s3]
}





module "sonarqube" {
  source = "./modules/sonarqube"
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  key_pair_name     = var.key_pair_name
  project_name      = var.project_name
  
  depends_on = [module.vpc]
}

module "ssm_secrets" {
  source = "./modules/ssm-secrets"

  sonar_token_name        = "/cicd/sonar/sonar-token"
  sonar_token             = var.sonar_token

  docker_username_name    = "/cicd/docker-credentials/username"
  docker_username         = var.docker_username

  docker_password_name    = "/cicd/docker-credentials/password"
  docker_password         = var.docker_password
}
