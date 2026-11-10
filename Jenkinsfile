
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
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD'
            }
        }

        stage('Validate Deployment Config') {
            steps {
                sh '''
                    test -f deployment/docker-compose.ec2.yml
                    test -f infrastructure/terraform/environments/staging/ecr-push.tf
                    echo "Deployment files verified"
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "
                            set -e
                            cd ${DEPLOY_DIR}
                            git fetch origin develop
                            git checkout develop
                            git pull --ff-only origin develop
                            aws ecr get-login-password --region ${AWS_REGION} |
                              docker login --username AWS --password-stdin 240571106446.dkr.ecr.${AWS_REGION}.amazonaws.com
                            docker compose --env-file .env -f deployment/docker-compose.ec2.yml pull user-service product-service order-service
                            docker compose --env-file .env -f deployment/docker-compose.ec2.yml up -d --build
                            curl --fail --retry 10 --retry-delay 5 http://localhost/health
                        "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Microservices deployed and health check passed.'
        }
        failure {
            echo 'FAILED: Check the Jenkins console output.'
        }
    }
}
