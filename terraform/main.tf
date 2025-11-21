terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket       = var.tf_state_bucket
    key          = var.tf_state_key
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------
# OIDC Identity Provider for GitHub
# ---------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# ---------------------------------------------------------
# Allowed GitHub OIDC Sub Claims
# ---------------------------------------------------------
locals {
  allowed_subs = [
    for branch in var.github_allowed_branches :
    "repo:${var.github_repo}:ref:refs/heads/${branch}"
  ]
}

# ---------------------------------------------------------
# IAM Role for GitHub Actions
# ---------------------------------------------------------
resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubOIDC"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : local.allowed_subs
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------------
# IAM Policy (Org, EKS, Lambda, infra, S3 backend, etc.)
# ---------------------------------------------------------
resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-terraform-policy"
  description = "Policy for GitHub Actions via OIDC to deploy AWS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # General AWS infra
      {
        Sid    = "BaseInfra"
        Effect = "Allow"
        Action = [
          "s3:*",
          "ec2:*",
          "cloudformation:*"
        ]
        Resource = "*"
      },

      # IAM (full control)
      {
        Sid    = "IAMAccess"
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = "*"
      },

      # AWS Organizations
      {
        Sid    = "OrganizationsAccess"
        Effect = "Allow"
        Action = [
          "organizations:*"
        ]
        Resource = "*"
      },

      # EKS
      {
        Sid    = "EKSAccess"
        Effect = "Allow"
        Action = [
          "eks:*",
          "iam:PassRole",
          "ec2:*"
        ]
        Resource = "*"
      },

      # Lambda
      {
        Sid    = "LambdaAccess"
        Effect = "Allow"
        Action = [
          "lambda:*",
          "logs:*"
        ]
        Resource = "*"
      },

      # Terraform backend S3 bucket
      {
        Sid    = "TerraformStateAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.tf_state_bucket}",
          "arn:aws:s3:::${var.tf_state_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_policy_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
