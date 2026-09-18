terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
    github = {
      source = "integrations/github"
      version = "~> 6.0"
    }
  }
}

module "ecr" {
  source = "./modules/ecr"

  project_name = "nestjs"
  ecr_repo_name = "terraform-repository"
}

module "iam" {
  source = "./modules/iam"

  role_name = "terraform-nestjs-deploy"
}

module "ec2" {
  source = "./modules/ec2"

  instance_name = "terraform-nestjs-ec2"
  instance_type = "t3.micro"
  iam_instance_profile = module.iam.instance_profile_name
  aws_region = var.aws_region
  account_id = var.account_id
  ecr_repo_name = module.ecr.repository_name
}

module "github_iam" {
  source = "./modules/github_iam"

  repository_arn = module.ecr.repository_arn
  ec2_instance_id = module.ec2.instance_id
}

module "rds" {
  source = "./modules/rds"

  ec2_security_group_id = module.ec2.security_group_id
}

# module "github" {
#   source = "./modules/github"
  
#   repository_name = var.github_repo_name
#   repository_owner = var.github_owner

#   secrets_map = {
#     "AWS_ROLE_TO_ASSUME" = module.github_iam.role_arn
#     "AWS_REGION" = var.aws_region
#     "AWS_ECR_REPO" = module.ecr.repository_name
#     "EC2_INSTANCE_ID" = module.ec2.instance_id
#   }
# }

resource "github_actions_secret" "repo_secrets" {
  for_each = {
    "AWS_ROLE_TO_ASSUME" = module.github_iam.role_arn
    "AWS_REGION" = var.aws_region
    "AWS_ECR_REPO" = module.ecr.repository_name
    "EC2_INSTANCE_ID" = module.ec2.instance_id
  }

  repository = var.github_repo_name
  secret_name = each.key
  value = each.value
}
