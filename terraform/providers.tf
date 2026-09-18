provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
