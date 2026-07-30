# Task Management Platform Runbook

This guide contains the commands I use to create, check, remove, and rebuild the AWS development environment.

> **Important:** destroying the development environment also deletes the RDS database and its data. The Terraform backend in `infra/terraform/bootstrap` is kept so the environment can be created again later.

## Before you start

Make sure Docker Desktop is running and that Terraform, Git, Docker, and the AWS CLI are installed.

From the repository root, confirm that AWS is using the correct account:

```bash
aws sts get-caller-identity
```

Set a few values that are reused later:

```bash
export AWS_REGION="eu-west-1"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
```

## First deployment

The first deployment has an extra step. The ECR repositories must exist before the first frontend and backend images can be pushed.

### 1. Open the Terraform development folder

```bash
cd infra/terraform/environments/dev
```

### 2. Initialize Terraform

```bash
terraform init -reconfigure -backend-config=backend.hcl
```

### 3. Create the local variable file

Only run this when `terraform.tfvars` does not exist yet:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and check the AWS account, region, domain, VPC CIDR, environment name, and image tags.

The file is ignored by Git because it contains local environment values.

### 4. Format and validate the Terraform code

```bash
terraform fmt -recursive ../..
terraform validate
```

### 5. Create the ECR repositories

At this point, create only the ECR module:

```bash
terraform plan \
  -target=module.ecr \
  -parallelism=1 \
  -out=ecr.tfplan
```

Review the plan and apply it:

```bash
terraform apply ecr.tfplan
rm -f ecr.tfplan
```

### 6. Build and push the first images

Return to the repository root:

```bash
cd ../../../..
```

Use the current Git commit as the image tag:

```bash
export IMAGE_TAG="$(git rev-parse HEAD)"
echo "${IMAGE_TAG}"
```

Update these two values in `infra/terraform/environments/dev/terraform.tfvars`:

```hcl
frontend_image_tag = "<IMAGE_TAG>"
backend_image_tag  = "<IMAGE_TAG>"
```

Log in to Amazon ECR:

```bash
aws ecr get-login-password --region "${AWS_REGION}" |
docker login \
  --username AWS \
  --password-stdin "${ECR_REGISTRY}"
```

Build and push the backend image:

```bash
docker build \
  -t "${ECR_REGISTRY}/task-management-dev-backend:${IMAGE_TAG}" \
  backend

docker push \
  "${ECR_REGISTRY}/task-management-dev-backend:${IMAGE_TAG}"
```

Build and push the frontend image:

```bash
docker build \
  -t "${ECR_REGISTRY}/task-management-dev-frontend:${IMAGE_TAG}" \
  frontend

docker push \
  "${ECR_REGISTRY}/task-management-dev-frontend:${IMAGE_TAG}"
```

### 7. Create the rest of the AWS environment

Go back to the Terraform development folder:

```bash
cd infra/terraform/environments/dev
```

Create a full plan:

```bash
terraform plan \
  -parallelism=1 \
  -out=deploy-dev.tfplan
```

Review the plan before applying it:

```bash
terraform apply deploy-dev.tfplan
rm -f deploy-dev.tfplan
```

Show the Terraform outputs:

```bash
terraform output
```

## Check the deployment

### ECS services

```bash
AWS_PAGER="" aws ecs describe-services \
  --region "${AWS_REGION}" \
  --cluster task-management-dev-ecs-cluster \
  --services \
    task-management-dev-backend-service \
    task-management-dev-frontend-service \
  --query 'services[].{
    Service:serviceName,
    Desired:desiredCount,
    Running:runningCount,
    Pending:pendingCount,
    Rollout:deployments[0].rolloutState
  }' \
  --output table
```

A healthy result should show:

```text
Desired: 1
Running: 1
Pending: 0
Rollout: COMPLETED
```

### Website and API

```bash
curl -I https://tasks.hashim-next-gen.com
curl -sS https://tasks.hashim-next-gen.com/api/tasks
```

The website should return an HTTP success response, and the API should return JSON.

### Image tags used by ECS

Backend:

```bash
AWS_PAGER="" aws ecs describe-task-definition \
  --region "${AWS_REGION}" \
  --task-definition task-management-dev-backend \
  --query 'taskDefinition.containerDefinitions[0].image' \
  --output text
```

Frontend:

```bash
AWS_PAGER="" aws ecs describe-task-definition \
  --region "${AWS_REGION}" \
  --task-definition task-management-dev-frontend \
  --query 'taskDefinition.containerDefinitions[0].image' \
  --output text
```

Both image addresses should end with a Git commit SHA instead of `latest`.

## Normal application updates

After the first deployment, application updates are handled by GitHub Actions.

```text
Push or merge to main
→ GitHub Actions authenticates to AWS through OIDC
→ New frontend and backend images are built
→ Images are pushed to ECR
→ New ECS task-definition revisions are registered
→ Both ECS services are updated
```

Terraform is still used when the AWS infrastructure itself changes.

## Destroy the development environment

The ECR repositories contain Docker images, so they must be removed with `--force` before Terraform can complete the destroy.

Make sure you are in:

```bash
cd infra/terraform/environments/dev
```

Initialize Terraform when needed:

```bash
terraform init -reconfigure -backend-config=backend.hcl
```

Delete the backend and frontend ECR repositories:

```bash
aws ecr delete-repository \
  --region "${AWS_REGION}" \
  --repository-name task-management-dev-backend \
  --force

aws ecr delete-repository \
  --region "${AWS_REGION}" \
  --repository-name task-management-dev-frontend \
  --force
```

Create a fresh destroy plan:

```bash
terraform plan \
  -destroy \
  -parallelism=1 \
  -out=destroy-dev.tfplan
```

Review the plan carefully, then apply it:

```bash
terraform apply destroy-dev.tfplan
rm -f destroy-dev.tfplan
```

Confirm that the development state is empty:

```bash
terraform state list
```

No output means the development resources have been removed.

Do not destroy the bootstrap configuration during normal cleanup:

```bash
# Do not run this during normal cleanup
terraform -chdir=../../bootstrap destroy
```

The bootstrap S3 bucket keeps the remote state setup available for the next rebuild.

## Rebuild after a destroy

The rebuild follows the same order as the first deployment:

```text
Initialize Terraform
→ Create the ECR repositories
→ Build and push both Docker images
→ Apply the full Terraform configuration
→ Check ECS, HTTPS, and the API
```

Start again from the **First deployment** section.

## Troubleshooting

### ECR repository is not empty

Delete the repository and its images:

```bash
aws ecr delete-repository \
  --region "${AWS_REGION}" \
  --repository-name <repository-name> \
  --force
```

After a failed destroy, remove the old plan and create a fresh one:

```bash
rm -f destroy-dev.tfplan

terraform plan \
  -destroy \
  -parallelism=1 \
  -out=destroy-dev.tfplan
```

### Check recent ECS service events

```bash
AWS_PAGER="" aws ecs describe-services \
  --region "${AWS_REGION}" \
  --cluster task-management-dev-ecs-cluster \
  --services task-management-dev-backend-service \
  --query 'services[0].events[0:10].[createdAt,message]' \
  --output table
```

### Backend logs

```bash
aws logs tail /ecs/task-management-dev/backend \
  --region "${AWS_REGION}" \
  --since 15m
```

### Frontend logs

```bash
aws logs tail /ecs/task-management-dev/frontend \
  --region "${AWS_REGION}" \
  --since 15m
```

### Terraform validation

When VS Code shows old module errors, use the Terraform CLI as the source of truth:

```bash
terraform validate
```

When Terraform or the local network becomes unstable, retry with limited parallelism:

```bash
terraform plan -parallelism=1
```
