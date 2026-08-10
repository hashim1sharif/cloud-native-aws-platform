data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
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
        "repo:hashim1sharif@97352574/task-management-platform@1312772280:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name = "${local.project_environment_name}-github-actions-deploy-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

data "aws_iam_policy_document" "github_actions_deploy_permissions" {
  statement {
    sid = "GetEcrAuthorizationToken"

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "PushApplicationImages"

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${module.ecr.frontend_repository_name}",
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${module.ecr.backend_repository_name}"
    ]
  }

  statement {
    sid = "ManageTaskDefinitions"

    effect = "Allow"

    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:TagResource"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "DeployApplicationServices"

    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]

    resources = [
      "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:service/${module.ecs.cluster_name}/${module.ecs.frontend_service_name}",
      "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:service/${module.ecs.cluster_name}/${module.ecs.backend_service_name}"
    ]
  }

  statement {
    sid = "PassEcsTaskExecutionRole"

    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      module.ecs.task_execution_role_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_deploy_permissions" {
  name = "${local.project_environment_name}-github-actions-deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = data.aws_iam_policy_document.github_actions_deploy_permissions.json
}