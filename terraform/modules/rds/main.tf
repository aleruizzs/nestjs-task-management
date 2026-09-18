data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default-subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db-subnet-group"
  subnet_ids = data.aws_subnets.default-subnets.ids

  tags = {
    Name = "RDS default subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  description = "SG for RDS instance"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "db_password" {
  length = 20
  special = false
}
resource "random_password" "jwt_secret" {
  length = 32
  special = false
}

resource "aws_db_instance" "this" {
  identifier = "nestjs-postgres-db"
  allocated_storage = 20
  engine = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  db_name = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
}

resource "aws_ssm_parameter" "app_secrets_val" {
  name = "/nestjs/env"
  type = "SecureString"

  value = jsonencode({
    DB_HOST = aws_db_instance.this.address
    DB_PORT = tostring(aws_db_instance.this.port)
    DB_USERNAME = var.db_username
    DB_PASSWORD = random_password.db_password.result
    DB_DATABASE = var.db_name
    JWT_SECRET = random_password.jwt_secret.result
  })
}