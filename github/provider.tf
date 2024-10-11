terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = module.vars.provider_profile
  region  = module.vars.provider_region
}

provider "github" {
  token = var.git_token
  owner = var.git_owner
}
