locals {
  repository_name = "${var.project_name}-${var.ecr_repo_name}"
}

resource "aws_ecr_repository" "ecr_repository" {
  name = local.repository_name
  image_tag_mutability = var.image_mutability
}