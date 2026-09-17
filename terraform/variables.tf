variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
  default = "eu-west-3"
}

variable "github_token" {
  type = string
  description = "PAT github with repo permissions"
  sensitive = true
}

variable "github_owner" {
  type = string
}

variable "github_repo_name" {
  type = string
  default = "nestjs-task-management"
}

variable "account_id" {
  type = string
}

variable "aws_access_key_id" {
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  type        = string
  sensitive   = true
  default     = ""
}
