# GitHub OIDC 제공자 생성
resource "aws_iam_openid_connect_provider" "oidc_github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c"] # GitHub OIDC의 Thumbprint
}

# GitHub Actions 워크플로우에 필요한 IAM 역할
resource "aws_iam_role" "github_workflow_role" {
  name = "github_workflow_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.oidc_github.url, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(aws_iam_openid_connect_provider.oidc_github.url, "https://", "")}:sub" = "repo:${var.git_owner}/${module.vars.github_app_repo_name}:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "github_workflow_policy" {
  name = "GitHubWorkflowPolicy"
  role = aws_iam_role.github_workflow_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECRAuthorization",
        Effect = "Allow",
        Action = "ecr:GetAuthorizationToken",
        Resource = "*"
      },
      {
        Sid    = "ECRPullPushPermissions",
        Effect = "Allow",
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "${aws_ecr_repository.my_app_repo.arn}"
      }
    ]
  })
}
