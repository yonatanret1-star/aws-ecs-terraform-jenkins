# AWS ECS DevOps CI/CD Pipeline

## Overview

This project demonstrates a complete containerized application deployment workflow using Docker, AWS, Terraform, and Jenkins.

The application consists of a React frontend and a Node.js/Express backend. The backend generates a GUID, and the frontend retrieves and displays that GUID.

The application was first tested locally with Docker, then deployed to AWS ECS using Fargate. Terraform was used to provision the AWS infrastructure, and Jenkins was configured to automate the Docker build, ECR push, and ECS deployment process.

## Technologies Used

- AWS ECS Fargate
- Amazon ECR
- Application Load Balancer
- Amazon VPC
- AWS IAM
- EC2
- Terraform
- Docker
- Jenkins
- GitHub
- React
- Node.js
- Express
- AWS CLI

## Architecture

```text
GitHub Repository
        |
        v
     Jenkins
        |
        v
 Docker Build
        |
        v
   Amazon ECR
        |
        v
  Amazon ECS
   (Fargate)
        |
        v
Application Load Balancer
        |
        +-------------------+
        |                   |
        v                   v
Frontend ECS Task      Backend ECS Task
Port 3000              Port 8080
        |                   |
        +------ /api/ -------+
                |
                v
             GUID
```

The Application Load Balancer provides the public entry point to the application.

- Frontend traffic is routed to the frontend ECS service.
- Requests to `/api/` are routed to the backend ECS service.
- The backend generates a GUID.
- The frontend displays the GUID returned by the backend.

## Project Structure

```text
devops-code-challenge1/
├── backend/
│   ├── Dockerfile
│   ├── config.js
│   ├── index.js
│   └── package.json
│
├── frontend/
│   ├── Dockerfile
│   ├── src/
│   │   ├── App.js
│   │   └── config.js
│   └── package.json
│
├── terraform/
│   ├── autoscaling.tf
│   ├── ecs.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── networking.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── variables.tf
│
├── screenshots/
│   ├── local-docker/
│   ├── ecr/
│   ├── ecs/
│   └── jenkins/
│
├── Jenkinsfile
├── .gitignore
└── README.md
```

## Local Application Testing

The frontend and backend were first tested locally.

### Backend

```bash
cd backend
npm install
npm start
```

The backend runs on:

```text
http://localhost:8080
```

### Frontend

```bash
cd frontend
npm install
npm start
```

The frontend runs on:

```text
http://localhost:3000
```

The frontend calls the backend and displays the GUID returned by the API.

## Docker

Dockerfiles were created for both application components.

### Build Backend

```bash
cd backend
docker build --platform linux/amd64 -t challenge-backend .
```

### Build Frontend

```bash
cd frontend
docker build --platform linux/amd64 -t challenge-frontend .
```

### Run Backend

```bash
docker run --rm -p 8080:8080 challenge-backend
```

### Run Frontend

```bash
docker run --rm -p 3000:3000 challenge-frontend
```

The running containers can be verified with:

```bash
docker ps
```

### Local Docker Containers

![Local Docker Containers](screenshots/local-docker/01-local-docker-containers.png)

### Local Application

![Local Frontend GUID](screenshots/local-docker/02-local-frontend-guid.png)

## Amazon ECR

Two Amazon ECR repositories were created:

```text
challenge-backend
challenge-frontend
```

The Docker images were tagged and pushed to ECR.

Example:

```bash
docker tag challenge-backend:latest \
AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/challenge-backend:latest

docker push \
AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/challenge-backend:latest
```

The same process was used for the frontend image.

### Backend ECR Image

![Backend ECR Image](screenshots/ecr/03-ecr-backend-image.png)

### Frontend ECR Image

![Frontend ECR Image](screenshots/ecr/04-ecr-frontend-image.png)

## Terraform Infrastructure

Terraform was used to provision the AWS application infrastructure.

The configuration creates resources including:

- VPC
- Internet Gateway
- Public subnets
- Route tables
- Security groups
- Application Load Balancer
- Target groups
- ECS cluster
- ECS task definitions
- ECS services
- IAM roles
- Application Auto Scaling

Terraform was initialized and validated with:

```bash
terraform init
terraform fmt
terraform validate
```

The deployment plan was reviewed with:

```bash
terraform plan
```

The infrastructure was then created with:

```bash
terraform apply
```

## ECS and Fargate

The frontend and backend run as separate ECS services using AWS Fargate.

### Frontend

```text
Container port: 3000
Desired tasks: 1
```

### Backend

```text
Container port: 8080
Desired tasks: 1
```

The ECS services use the Docker images stored in Amazon ECR.

## Application Load Balancer

An Application Load Balancer routes traffic to the ECS services.

```text
/       -> Frontend target group
/api/*  -> Backend target group
```

The frontend uses the same load balancer to reach the backend API.

## Auto Scaling

Application Auto Scaling was configured for both ECS services.

```text
Minimum tasks: 1
Maximum tasks: 4
CPU target: 50%
```

When average CPU utilization increases above the configured target, ECS can increase the number of running tasks.

## AWS Hosted Application

The deployed application is accessible through the Application Load Balancer.

The frontend successfully communicates with the backend and displays the GUID returned by the backend service.

![AWS Hosted Frontend](screenshots/ecs/05-aws-frontend-guid.png)

## Jenkins CI/CD

Jenkins was installed on an EC2 instance and configured as the CI/CD server.

The Jenkins server uses:

- Java 21
- Docker
- Git
- AWS CLI
- GitHub credentials
- EC2 IAM role

The EC2 instance uses the IAM role:

```text
JenkinsEcsDeployRole
```

This allows Jenkins to authenticate to AWS without storing AWS access keys directly in Jenkins.

## Jenkins Pipeline

The pipeline configuration is stored in the repository as:

```text
Jenkinsfile
```

The pipeline performs the following workflow:

```text
GitHub Checkout
      |
      v
ECR Authentication
      |
      v
Build Backend Docker Image
      |
      v
Build Frontend Docker Image
      |
      v
Push Backend Image to ECR
      |
      v
Push Frontend Image to ECR
      |
      v
Redeploy Backend ECS Service
      |
      v
Redeploy Frontend ECS Service
```

The ECS services are redeployed using:

```bash
aws ecs update-service \
  --cluster devops-challenge-cluster \
  --service SERVICE_NAME \
  --force-new-deployment \
  --region us-east-1
```

## Successful Jenkins Deployment

The Jenkins pipeline successfully completed the Docker build, ECR push, and ECS deployment process.

![Jenkins Build Success](screenshots/jenkins/06-jenkins-build-success.png)

### Jenkins Console Output

The final Jenkins console output confirms the pipeline completed successfully.

![Jenkins Console Success](screenshots/jenkins/07-jenkins-console-success.png)

## Deployment Workflow

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    +--> Build Backend Image
    |
    +--> Build Frontend Image
    |
    v
Amazon ECR
    |
    v
Amazon ECS Fargate
    |
    v
Application Load Balancer
    |
    v
AWS Hosted Application
```

## Troubleshooting

### Docker Image Architecture

The ECS tasks require Linux AMD64 compatible images.

Images were built using:

```bash
docker build --platform linux/amd64 ...
```

### ECS Backend 503 Error

The Application Load Balancer initially returned a `503 Service Temporarily Unavailable` response because the backend ECS task could not pull the image.

The ECS service events showed:

```text
image Manifest does not contain descriptor matching platform 'linux/amd64'
```

Rebuilding and pushing the backend image for `linux/amd64` resolved the issue.

### Jenkins Disk Space

The Jenkins EC2 instance initially had insufficient disk space.

The EBS root volume was increased to 20 GB and the Linux root partition was expanded.

### Jenkins Memory

The frontend Docker build initially failed with:

```text
exit code 137
```

The Jenkins EC2 instance had approximately 2 GB of RAM and no swap space.

A 2 GB swap file was added:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

After adding swap space, the Jenkins pipeline completed successfully.

## Security

The project uses several security practices:

- GitHub repository is private.
- AWS credentials are provided to Jenkins through an EC2 IAM role.
- AWS access keys are not stored in the Jenkins pipeline.
- Jenkins GitHub access uses a scoped personal access token.
- Terraform state files are excluded from Git.
- Terraform provider directories are excluded from Git.
- Jenkins port 8080 is restricted through the EC2 security group.
- ECS services use security groups to restrict application traffic.

## Git Ignore

Terraform state and provider files are excluded from the repository:

```gitignore
node_modules/

# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log
```

The Terraform lock file is intentionally committed:

```text
terraform/.terraform.lock.hcl
```

## Result

This project demonstrates an end-to-end DevOps deployment workflow using Docker, Terraform, AWS ECR, AWS ECS Fargate, an Application Load Balancer, and Jenkins CI/CD.

The final application is deployed to AWS, and the Jenkins pipeline can automatically build the frontend and backend containers, push the images to Amazon ECR, and redeploy both ECS services.
