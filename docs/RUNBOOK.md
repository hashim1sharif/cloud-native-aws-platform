# Task Management Platform Runbook

This runbook contains the operational commands for deploying, verifying, destroying, and recreating the AWS development environment.

> Destroying the development environment removes RDS and the current application data. Do not destroy the Terraform bootstrap resources during normal cleanup.

## 1. Set shell variables

```bash
export AWS_REGION="eu-west-1"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
```

## 2. Initialize Terraform

```bash
terraform -chdir=infra/terraform/environments/dev init \
  -reconfigure \
  -backend-config=backend.hcl
```

## 3. Create the local values file

```bash
cp \
  infra/terraform/environments/dev/terraform.tfvars.example \
  infra/terraform/environments/dev/terraform.tfvars
```

Update the copied file with the correct account, region, domain, environment, VPC CIDR, and image tags.

## 4. Validate

```bash
terraform fmt -recursive infra/terraform
terraform -chdir=infra/terraform/environments/dev validate
```

## 5. Create ECR first

```bash
terraform -chdir=infra/terraform/environments/dev plan \
  -target=module.ecr \
  -parallelism=1 \
  -out=ecr.tfplan

terraform -chdir=infra/terraform/environments/dev apply ecr.tfplan
rm -f infra/terraform/environments/dev/ecr.tfplan
```

## 6. Build immutable images

```bash
export IMAGE_TAG="$(git rev-parse HEAD)"
echo "${IMAGE_TAG}"
```

Update the ignored `terraform.tfvars` file:

```bash
sed -i \
  "s/^frontend_image_tag.*/frontend_image_tag = \"${IMAGE_TAG}\"/" \
  infra/terraform/environments/dev/terraform.tfvars

sed -i \
  "s/^backend_image_tag.*/backend_image_tag  = \"${IMAGE_TAG}\"/" \
  infra/terraform/environments/dev/terraform.tfvars
```

Log in to ECR:

```bash
aws ecr get-login-password --region "${AWS_REGION}" |
docker login \
  --username AWS \
  --password-stdin "${ECR_REGISTRY}"
```

Build and push the backend:

```bash
docker build \
  --tag "${ECR_REGISTRY}/task-management-dev-backend:${IMAGE_TAG}" \
  backend

docker push \
  "${ECR_REGISTRY}/task-management-dev-backend:${IMAGE_TAG}"
```

Build and push the frontend:

```bash
docker build \
  --tag "${ECR_REGISTRY}/task-management-dev-frontend:${IMAGE_TAG}" \
  frontend

docker push \
  "${ECR_REGISTRY}/task-management-dev-frontend:${IMAGE_TAG}"
```

## 7. Deploy the full environment

```bash
terraform -chdir=infra/terraform/environments/dev plan \
  -parallelism=1 \
  -out=deploy-dev.tfplan

terraform -chdir=infra/terraform/environments/dev apply deploy-dev.tfplan
rm -f infra/terraform/environments/dev/deploy-dev.tfplan
```

Read outputs:

```bash
terraform -chdir=infra/terraform/environments/dev output
```

## 8. Verify ECS

```bash
AWS_PAGER="" aws ecs describe-services \
  --region eu-west-1 \
  --cluster task-management-dev-ecs-cluster \
  --services \
    task-management-dev-backend-service \
    task-management-dev-frontend-service \
  --query 'services[].{
    Service:serviceName,
    Desired:desiredCount,
    Running:runningCount,
    Pending:pendingCount,
    TaskDefinition:taskDefinition,
    Rollout:deployments[0].rolloutState
  }' \
  --output table
```

Healthy result:

```text
Desired: 1
Running: 1
Pending: 0
Rollout: COMPLETED
```

## 9. Verify HTTPS and API

```bash
curl -I https://tasks.hashim-next-gen.com
curl -sS https://tasks.hashim-next-gen.com/api/tasks
```

## 10. Confirm deployed image tags

```bash
AWS_PAGER="" aws ecs describe-task-definition \
  --region eu-west-1 \
  --task-definition task-management-dev-backend \
  --query 'taskDefinition.containerDefinitions[0].image' \
  --output text

AWS_PAGER="" aws ecs describe-task-definition \
  --region eu-west-1 \
  --task-definition task-management-dev-frontend \
  --query 'taskDefinition.containerDefinitions[0].image' \
  --output text
```

The image URI should end with a commit SHA, not `latest`.

## 11. Destroy the development environment

Delete the non-empty repositories first:

```bash
aws ecr delete-repository \
  --region eu-west-1 \
  --repository-name task-management-dev-backend \
  --force

aws ecr delete-repository \
  --region eu-west-1 \
  --repository-name task-management-dev-frontend \
  --force
```

Create and apply a saved destroy plan:

```bash
terraform -chdir=infra/terraform/environments/dev plan \
  -destroy \
  -parallelism=1 \
  -out=destroy-dev.tfplan

terraform -chdir=infra/terraform/environments/dev apply destroy-dev.tfplan
rm -f infra/terraform/environments/dev/destroy-dev.tfplan
```

Confirm the state is empty:

```bash
terraform -chdir=infra/terraform/environments/dev state list
```

Do not run:

```bash
terraform -chdir=infra/terraform/bootstrap destroy
```

## 12. Recreate after destroy

Use this order:

```text
Initialize dev backend
→ Apply ECR module
→ Build and push both images
→ Apply full environment
→ Verify ECS, HTTPS and API
```

## 13. Troubleshooting

### ECR blocks destroy

```bash
aws ecr delete-repository \
  --region eu-west-1 \
  --repository-name <repository-name> \
  --force
```

### ECS service events

```bash
AWS_PAGER="" aws ecs describe-services \
  --region eu-west-1 \
  --cluster task-management-dev-ecs-cluster \
  --services task-management-dev-backend-service \
  --query 'services[0].events[0:10].[createdAt,message]' \
  --output table
```

### Backend logs

```bash
aws logs tail /ecs/task-management-dev/backend \
  --region eu-west-1 \
  --since 15m
```

### Frontend logs

```bash
aws logs tail /ecs/task-management-dev/frontend \
  --region eu-west-1 \
  --since 15m
```

### Terraform concurrency or local networking problems

```bash
terraform -chdir=infra/terraform/environments/dev plan \
  -parallelism=1
```

### VS Code shows stale Terraform module errors

Use the CLI as the source of truth:

```bash
terraform -chdir=infra/terraform/environments/dev validate
```
