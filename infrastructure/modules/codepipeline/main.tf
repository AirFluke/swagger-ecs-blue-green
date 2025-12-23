resource "aws_codepipeline" "this" {
  name     = var.project_name
  role_arn = var.role_arn

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn     = var.connection_arn
        FullRepositoryId  = var.github_repo
        BranchName        = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]

      configuration = {
        ProjectName = var.codebuild_project
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build"]

      configuration = {
        ApplicationName     = var.codedeploy_app
        DeploymentGroupName = var.codedeploy_group
      }
    }
  }
}
