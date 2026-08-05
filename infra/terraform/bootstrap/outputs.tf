output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.s3_bucket.id
}

output "terraform_role_arn" {
  description = "ARN of the IAM role used by the Terraform GitHub Actions pipelines."
  value       = aws_iam_role.github_actions_terraform.arn
}