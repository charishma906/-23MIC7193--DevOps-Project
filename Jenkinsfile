pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Cloning source code from GitHub...'
                git branch: 'main', url: 'https://github.com/charishma906/-23MIC7193--DevOps-Project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image using Minikube Docker daemon...'
                bat '''
                @echo off
                FOR /F "tokens=*" %%i IN ('minikube -p minikube docker-env --shell cmd') DO @%%i
                docker build -t abc-corporate-website:latest .
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Applying Kubernetes manifests...'
                bat 'kubectl apply -f k8s\\deployment.yaml'
                bat 'kubectl apply -f k8s\\service.yaml'
                bat 'kubectl rollout status deployment/abc-website-deployment'
            }
        }

        stage('Verify Pods') {
            steps {
                bat 'kubectl get pods'
                bat 'kubectl get svc'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully - website built and deployed to Kubernetes.'
        }
        failure {
            echo 'Pipeline failed - check console output above.'
        }
    }
}
