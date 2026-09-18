resource "aws_iam_role" "ec2_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_default" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy" "ssm_parameters_policy" {
  name = "ssm-parameters-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowSSMGetParameters"
        Effect = "Allow"
        Action = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = ["arn:aws:ssm:*:*:parameter/nestjs/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_parameters_attach" {
  role = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ssm_parameters_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.role_name}-profile"
  role = aws_iam_role.ec2_role.name
}
