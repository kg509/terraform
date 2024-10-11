module "vars" {
  source = "../vars"
}

resource "github_repository" "app" {
  name       = module.vars.github_app_repo_name
  visibility = "private"
}

resource "github_repository" "manifest" {
  name       = module.vars.github_manifest_repo_name
  visibility = "private"
}

resource "aws_ecr_repository" "my_app_repo" {
  name         = module.vars.ecr_repo_name
  force_delete = true
}
