pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '678817681968'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        FRONTEND_REPO = 'challenge-frontend'
        BACKEND_REPO = 'challenge-backend'
        ECS_CLUSTER = 'devops-challenge-cluster'
        FRONTEND_SERVICE = 'devops-challenge-frontend-service'
        BACKEND_SERVICE = 'devops-challenge-backend-service'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('ECR Login') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REGISTRY
                '''
            }
        }

        stage('Build Backend') {
            steps {
                sh '''
                docker build --platform linux/amd64 \
                -t $BACKEND_REPO ./backend
                '''
            }
        }

        stage('Build Frontend') {
            steps {
                sh '''
                docker build --platform linux/amd64 \
                -t $FRONTEND_REPO ./frontend
                '''
            }
        }

        stage('Push Backend') {
            steps {
                sh '''
                docker tag $BACKEND_REPO:latest \
                $ECR_REGISTRY/$BACKEND_REPO:latest

                docker push \
                $ECR_REGISTRY/$BACKEND_REPO:latest
                '''
            }
        }

        stage('Push Frontend') {
            steps {
                sh '''
                docker tag $FRONTEND_REPO:latest \
                $ECR_REGISTRY/$FRONTEND_REPO:latest

                docker push \
                $ECR_REGISTRY/$FRONTEND_REPO:latest
                '''
            }
        }

        stage('Deploy Backend') {
            steps {
                sh '''
                aws ecs update-service \
                --cluster $ECS_CLUSTER \
                --service $BACKEND_SERVICE \
                --force-new-deployment \
                --region $AWS_REGION
                '''
            }
        }

        stage('Deploy Frontend') {
            steps {
                sh '''
                aws ecs update-service \
                --cluster $ECS_CLUSTER \
                --service $FRONTEND_SERVICE \
                --force-new-deployment \
                --region $AWS_REGION
                '''
            }
        }
    }
}
