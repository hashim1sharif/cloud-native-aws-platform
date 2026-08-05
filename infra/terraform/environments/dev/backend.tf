terraform {
  backend "s3" {
    bucket       = "task-management-platform-state-lock-eu-west-1"
    key          = "task-management/dev/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}