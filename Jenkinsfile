pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // ✅ Your actual region
        ECR_REPO_NAME = 'heathjavasamplerepo'
        ECR_REPO_URI = "345594588963.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO_NAME}"
        JAVA_HOME = tool name: 'jdk17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    tools {
        jdk 'jdk17'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/heathfrantz91-sys/heathjavasamplerepo.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh './mvnw clean package'
            }
        }

        stage('Login to AWS ECR & Ensure Repo Exists') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'AKIAVA5YK54RVVRW35GX',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        set -e

                        # Configure AWS CLI
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region $AWS_REGION

                        # Log in to ECR
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_REPO_URI

                        # Ensure ECR repo exists (create if not)
                        aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION || \
                        aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // Optional: clean cache to avoid stale errors
                // sh 'docker builder prune -f'

                sh 'docker build -t $ECR_REPO_URI:latest -f Dockerfile .'
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh 'docker push $ECR_REPO_URI:latest'
            }
        }
    }

    post {
        success {
            echo '✅ Build and push completed successfully.'
        }
        failure {
            echo '❌ Build failed.'
        }
    }
}
