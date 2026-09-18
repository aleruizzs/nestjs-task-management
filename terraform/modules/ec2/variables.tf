variable "instance_name" {
  type = string
  default = "nestjs-ec2-instance"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "iam_instance_profile" {
  type = string
  description = "Instance Profile name with permissions"
}

variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "ecr_repo_name" {
  type = string
}