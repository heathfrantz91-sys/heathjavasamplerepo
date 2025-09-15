pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2' // ✅ Corrected to match your ECR region
        ECR_REPO_URI = '345594588963.dkr.ecr.us-east-2.amazonaws.com/heathjavasamplerepo' // ✅ Your actual ECR URI
        JAVA_HOME = tool name: 'jdk17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    tools {
        jdk 'jdk17'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                sh './mvnw clean package'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'AKIAVA5YK54RVVRW35GX', // Jenkins credential ID for AWS
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region $AWS_REGION

                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_REPO_URI
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
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
