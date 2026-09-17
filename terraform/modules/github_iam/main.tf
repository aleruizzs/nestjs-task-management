resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::974389254652:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:aleruizzs/nestjs-task-management:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "deploy_policy" {
  name = "github-actions-deploy-policy"
  description = "Permissions for GitHub Actions to push to ECR and run SSM on EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowECRLogin"
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid = "AllowPushToECR"
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage"
        ]
        Resource = var.repository_arn
      },
      {
        Sid = "AllowSendCommandOnMyEC2"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand"
        ]
        Resource = [
          "arn:aws:ssm:*:*:document/AWS-RunShellScript",
          "arn:aws:ec2:*:*:instance/${var.ec2_instance_id}"
        ]
      },
      {
        Sid = "AllowCheckStatus"
        Effect = "Allow"
        Action = [
          "ssm:ListCommandInvocations",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "deploy_policy_attach" {
  role = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.deploy_policy.arn
}
