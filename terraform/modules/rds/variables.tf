variable "db_name" {
  type = string
  default = "tasks"
}

variable "db_username" {
  type = string
  default = "postgres"
}

variable "ec2_security_group_id" {
  type = string
  description = "EC2 SG that has access to the RDS instance"
}
