pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "173378532619"
        AWS_REGION     = "us-east-1"
        IMAGE_REPO     = "beyond-mumbai"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        CLUSTER_NAME   = "my-eks-cluster"
    }

    stages {

        stage('Login to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Build & Push Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_REPO}:${IMAGE_TAG} .
                    docker tag ${IMAGE_REPO}:${IMAGE_TAG} \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                    aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}

                    if kubectl get deployment my-app 2>/dev/null; then
                        kubectl set image deployment/my-app \
                        my-app=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}
                    else
                        kubectl apply -f k8s/deploy.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl set image deployment/my-app \
                        my-app=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}
                    fi

                    kubectl rollout status deployment/my-app
                """
            }
        }
    }

    post {
        success {
            sh """
                aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}
                echo "Deployment successful!"
                kubectl get service my-app-service
            """
        }
    }
}