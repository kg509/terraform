resource "github_actions_secret" "aws_region" {
  repository      = github_repository.app.name
  secret_name     = "AWS_REGION"
  plaintext_value = module.vars.aws_region
}

resource "github_actions_secret" "arn_ecr_push_role" {
  repository      = github_repository.app.name
  secret_name     = "ARN_ECR_PUSH_ROLE"
  plaintext_value = aws_iam_role.github_workflow_role.arn
}

resource "github_actions_secret" "ecr_repository" {
  repository      = github_repository.app.name
  secret_name     = "ECR_REPOSITORY"
  plaintext_value = aws_ecr_repository.my_app_repo.name
}

resource "github_actions_secret" "pat_token" {
  repository      = github_repository.app.name
  secret_name     = "PAT_TOKEN"
  plaintext_value = var.git_token
}

resource "github_actions_secret" "aws_account_id" {
  repository      = github_repository.app.name
  secret_name     = "AWS_ACCOUNT_ID"
  plaintext_value = data.aws_caller_identity.current.account_id
}

resource "github_actions_secret" "git_email" {
  repository      = github_repository.app.name
  secret_name     = "GIT_EMAIL"
  plaintext_value = var.git_email
}

resource "github_actions_secret" "git_name" {
  repository      = github_repository.app.name
  secret_name     = "GIT_NAME"
  plaintext_value = var.git_name
}

resource "github_actions_secret" "manifest_repo" {
  repository      = github_repository.app.name
  secret_name     = "MANIFEST_REPO"
  plaintext_value = github_repository.manifest.full_name
}
