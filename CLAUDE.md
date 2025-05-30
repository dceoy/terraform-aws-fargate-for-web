# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Infrastructure Management
```bash
# Build Docker image
./docker_buildx_bake.sh

# Initialize Terraform/Terragrunt
terragrunt run-all init --working-dir='envs/dev/' -upgrade -reconfigure

# Plan infrastructure changes
terragrunt run-all plan --working-dir='envs/dev/'

# Apply infrastructure changes
terragrunt run-all apply --working-dir='envs/dev/' --non-interactive

# Destroy infrastructure
terragrunt run-all destroy --working-dir='envs/dev/' --non-interactive
```

### Development
```bash
# Install Python dependencies
poetry install

# Run Python linter
poetry run ruff check src/

# Run Python type checker
poetry run pyright src/

# Run Streamlit app locally
poetry run streamlit run src/app.py
```

### Docker & ECR
```bash
# Build and tag Docker image
export REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export TAG="sha-$(git rev-parse --short HEAD)"
docker buildx bake --pull --load --provenance=false

# Push to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY}
docker image push ${REGISTRY}/streamlit-app:${TAG}
```

## Architecture

This project deploys a Streamlit web application on AWS Fargate using Terraform and Terragrunt.

### Key Components

1. **Infrastructure as Code**: Uses Terragrunt to manage multiple Terraform modules with hierarchical configuration
   - `envs/root.hcl`: Global configuration including remote state, provider generation, and common inputs
   - `envs/dev/env.hcl`: Environment-specific variables (account ID, region, system name)
   - Individual module directories under `envs/dev/` reference modules from `modules/`

2. **Module Structure**: Custom Terraform modules in `modules/` directory
   - `vpc`, `subnet`, `nat`: Network infrastructure
   - `ecr`: Container registry for Docker images
   - `ecscluster`, `ecstask`, `ecsservice`: ECS/Fargate components
   - `alb`: Application Load Balancer
   - `acm`: SSL certificates
   - `kms`, `s3`: Supporting services

3. **Container Configuration**:
   - Docker image built from `src/Dockerfile` using multi-stage build
   - Streamlit app served on port 8501
   - Container definitions template at `envs/ecs-task-container-definitions.json.tpl`
   - ARM64 architecture by default (configurable via `fargate_architecture`)

4. **Deployment Flow**:
   - Docker image is built locally using `docker_buildx_bake.sh`
   - Image is pushed to ECR
   - Terragrunt applies infrastructure changes
   - ECS service pulls the image and runs containers on Fargate

5. **Configuration Management**:
   - All infrastructure inputs are centralized in `envs/root.hcl`
   - Module dependencies are automatically handled by Terragrunt
   - Docker build configuration in `docker-bake.hcl`