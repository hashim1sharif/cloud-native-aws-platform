# Allows Amazon ECS tasks to assume the task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.project_environment_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Gives ECS permission to pull ECR images and send logs to CloudWatch
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allows ECS to inject the RDS-managed credentials into the backend container
resource "aws_iam_role_policy" "ecs_task_execution_secrets_policy" {
  name = "${local.project_environment_name}-ecs-secrets-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          aws_db_instance.postgres_db_instance.master_user_secret[0].secret_arn
        ]
      }
    ]
  })
}