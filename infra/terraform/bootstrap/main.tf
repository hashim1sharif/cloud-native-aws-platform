resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = var.state_bucket_name
    Project   = "task-management"
    ManagedBy = "Terraform"
    Purpose   = "Terraform remote state"
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions_terraform_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        var.github_oidc_subject
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_terraform" {
  name = "task-management-terraform-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_assume_role.json
}

data "aws_iam_policy_document" "github_actions_terraform_permissions" {
  statement {
    sid    = "ListTerraformState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.s3_bucket.arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "task-management/dev/*"
      ]
    }
  }

  statement {
    sid    = "ReadWriteTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/task-management/dev/terraform.tfstate",
      "${aws_s3_bucket.s3_bucket.arn}/task-management/dev/terraform.tfstate.tflock"
    ]
  }

  statement {
    sid    = "DeleteTerraformLock"
    effect = "Allow"

    actions = [
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/task-management/dev/terraform.tfstate.tflock"
    ]
  }

  statement {
    sid    = "ManageApplicationInfrastructure"
    effect = "Allow"

    actions = [
      "acm:*",
      "ec2:*",
      "ecr:*",
      "ecs:*",
      "elasticloadbalancing:*",
      "logs:*",
      "rds:*",
      "route53:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ManageRdsCredentials"
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "secretsmanager:CreateSecret",
      "secretsmanager:TagResource"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ManageProjectIamRoles"
    effect = "Allow"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy"
    ]

    resources = [
      "arn:aws:iam::${var.aws_account_id}:role/task-management-dev-*"
    ]
  }

  statement {
    sid    = "PassEcsTaskExecutionRole"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::${var.aws_account_id}:role/task-management-dev-ecs-task-execution-role"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "ReadGithubOidcProvider"
    effect = "Allow"

    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CreateRequiredServiceLinkedRoles"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"

      values = [
        "ecs.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "rds.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_terraform_permissions" {
  name = "task-management-terraform-policy"
  role = aws_iam_role.github_actions_terraform.id

  policy = data.aws_iam_policy_document.github_actions_terraform_permissions.json
}