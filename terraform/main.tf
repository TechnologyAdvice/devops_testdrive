terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  ecr_name = "devops-testdrive-static-site"
}

resource "aws_ecr_repository" "app" {
  name = local.ecr_name
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]
}

data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:*/*:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions_push" {
  name               = "github-actions-${local.ecr_name}-push"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
}

data "aws_iam_policy_document" "ecr_push_broad" {
  statement {
    sid = "ECR"

    actions = [
      "ecr:*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_push" {
  name   = "ecr-push-all"
  role   = aws_iam_role.github_actions_push.id
  policy = data.aws_iam_policy_document.ecr_push_broad.json
}
