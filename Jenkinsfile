pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = "<DOCKERHUB_USERNAME>/abc-corporate-website"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Cloning source code from GitHub...'
                git branch: 'main', url: 'https://github.com/<YOUR_USERNAME>/<YOUR_REPO>.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Login to Docker Hub') {
            steps {
                sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing image to Docker Hub...'
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Applying Kubernetes manifests...'
                sh "sed -i 's#<DOCKERHUB_USERNAME>/abc-corporate-website:latest#${IMAGE_NAME}:${IMAGE_TAG}#' k8s/deployment.yaml"
                sh "kubectl apply -f k8s/deployment.yaml"
                sh "kubectl apply -f k8s/service.yaml"
                sh "kubectl rollout status deployment/abc-website-deployment"
            }
        }

        stage('Smoke Test') {
            steps {
                echo 'Verifying the website responds after deployment...'
                sh "curl -f http://localhost:30080/healthz"
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully - website deployed and healthy.'
        }
        failure {
            echo 'Pipeline failed - check console output above.'
        }
        always {
            sh 'docker logout'
        }
    }
}
