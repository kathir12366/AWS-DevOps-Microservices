
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 45, unit: 'MINUTES')
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        EC2_HOST = '43.205.140.154'
        EC2_USER = 'ubuntu'
        AWS_REGION = 'ap-south-1'
        DEPLOY_DIR = '/home/ubuntu/microservices-deploy'
        ECR_REGISTRY = '240571106446.dkr.ecr.ap-south-1.amazonaws.com'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD'
            }
        }

        stage('Validate Configuration') {
            steps {
                sh '''
                    test -f deployment/docker-compose.ec2.yml
                    test -f services/user-service/Dockerfile
                    test -f services/product-service/Dockerfile
                    test -f services/order-service/Dockerfile
                    test -f infrastructure/terraform/environments/staging/ecr-push.tf
                    echo "All deployment files verified"
                '''
            }
        }

        stage('Build, Scan, Push and Deploy') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'bash -s' <<'REMOTE'
                        set -e

                        cd /home/ubuntu/microservices-deploy

                        echo "Updating source code"
                        git fetch origin develop
                        git checkout develop
                        git pull --ff-only origin develop

                        echo "Logging in to AWS ECR"
                        aws ecr get-login-password --region ap-south-1 |
                          docker login --username AWS --password-stdin 240571106446.dkr.ecr.ap-south-1.amazonaws.com

                        echo "Building User Service"
                        docker build -t user-service:latest ./services/user-service

                        echo "Building Product Service"
                        docker build -t product-service:latest ./services/product-service

                        echo "Building Order Service"
                        docker build -t order-service:latest ./services/order-service

                        echo "Scanning User Service"
                        trivy image --severity HIGH,CRITICAL user-service:latest

                        echo "Scanning Product Service"
                        trivy image --severity HIGH,CRITICAL product-service:latest

                        echo "Scanning Order Service"
                        trivy image --severity HIGH,CRITICAL order-service:latest

                        echo "Tagging images for ECR"
                        ECR=240571106446.dkr.ecr.ap-south-1.amazonaws.com

                        docker tag user-service:latest $ECR/staging-user-service:latest
                        docker tag product-service:latest $ECR/staging-product-service:latest
                        docker tag order-service:latest $ECR/staging-order-service:latest

                        echo "Pushing images to ECR"
                        docker push $ECR/staging-user-service:latest
                        docker push $ECR/staging-product-service:latest
                        docker push $ECR/staging-order-service:latest

                        echo "Deploying updated services"
                        docker compose --env-file .env -f deployment/docker-compose.ec2.yml pull user-service product-service order-service

                        docker compose --env-file .env -f deployment/docker-compose.ec2.yml up -d

                        echo "Checking application health"
                        curl --fail --retry 10 --retry-delay 5 http://localhost/health

                        echo "CI/CD deployment completed successfully
 REMOTE
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Build, Trivy scan, ECR push and deployment completed.'
        }
        failure {
            echo 'FAILED: Check the Jenkins console output.'
        }
    }
}
