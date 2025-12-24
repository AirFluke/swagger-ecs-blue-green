resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_s3" {
  name = "codepipeline-s3-policy"
  role = aws_iam_role.codepipeline.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_codebuild" {
  name = "codepipeline-codebuild-policy"
  role = aws_iam_role.codepipeline.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = var.codebuild_project_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_codedeploy" {
  name = "codepipeline-codedeploy-policy"
  role = aws_iam_role.codepipeline.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_ecs" {
  name = "codepipeline-ecs-policy"
  role = aws_iam_role.codepipeline.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecs:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_passrole" {
  name = "codepipeline-passrole-policy"
  role = aws_iam_role.codepipeline.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy" "codepipeline_codestar" {
  name = "codepipeline-codestar-policy"
  role = aws_iam_role.codepipeline.name
  
  # Only create if codestar_connection_arn is provided
  count = var.codestar_connection_arn != "" && var.codestar_connection_arn != null ? 1 : 0
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "codestar-connections:UseConnection"
        Resource = var.codestar_connection_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_admin" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}



resource "aws_codepipeline" "this" {
  name     = "${var.project_name}-codepipeline"
  role_arn = var.role_arn

   artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"

    
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn     = var.codestar_connection_arn
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
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
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
      provider        = "CodeDeployToECS"
      input_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ApplicationName     = var.codedeploy_app
        DeploymentGroupName = var.codedeploy_group
        TaskDefinitionTemplateArtifact = "build_output"
        AppSpecTemplateArtifact        = "build_output"
     
      }
    }
  }
  tags = {
    Name = "${var.project_name}-pipeline"
  }
}
