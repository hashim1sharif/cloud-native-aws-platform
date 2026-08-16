# Stores Docker images for the frontend application
resource "aws_ecr_repository" "frontend_ecr_repository" {
  name                 = "${var.name_prefix}-frontend"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}

# Stores Docker images for the backend application
resource "aws_ecr_repository" "backend_ecr_repository" {
  name                 = "${var.name_prefix}-backend"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}

# Removes untagged frontend images after the configured number of days
resource "aws_ecr_lifecycle_policy" "frontend_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.frontend_ecr_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after ${var.untagged_image_expiration_days} days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiration_days
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Removes untagged backend images after the configured number of days
resource "aws_ecr_lifecycle_policy" "backend_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.backend_ecr_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after ${var.untagged_image_expiration_days} days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiration_days
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}
