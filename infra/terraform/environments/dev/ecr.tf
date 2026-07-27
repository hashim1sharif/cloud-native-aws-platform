# Stores Docker images for the frontend application
resource "aws_ecr_repository" "frontend_ecr_repository" {
  name                 = "${local.project_environment_name}-frontend"
  image_tag_mutability = "IMMUTABLE"
}

# Stores Docker images for the backend application
resource "aws_ecr_repository" "backend_ecr_repository" {
  name                 = "${local.project_environment_name}-backend"
  image_tag_mutability = "IMMUTABLE"
}

# Removes untagged frontend images after 14 days
resource "aws_ecr_lifecycle_policy" "frontend_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.frontend_ecr_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after 14 days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Removes untagged backend images after 14 days
resource "aws_ecr_lifecycle_policy" "backend_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.backend_ecr_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after 14 days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}