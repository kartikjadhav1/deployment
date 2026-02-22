pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "173378532619"
        AWS_REGION     = "us-east-1"
        IMAGE_REPO     = "beyond-mumbai"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CLUSTER_NAME   = "my-eks-cluster"
    }
    stages {
        stage('Login to ECR') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh '''
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        '''
                    }
                }
            }
        }
        stage('Build & Push Image') {
            steps {
                sh "docker build -t ${IMAGE_REPO}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_REPO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}"
                
                script {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh '''
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh '''
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}
                            
                            if kubectl get deployment beyond-mumbai-app 2>/dev/null; then
                                echo "Deployment exists, updating image..."
                                kubectl set image deployment/beyond-mumbai-app web-server=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}
                            else
                                echo "Deployment does not exist, creating it..."
                                kubectl apply -f k8s/deploy.yaml
                                kubectl apply -f k8s/service.yaml
                                sleep 5
                                kubectl set image deployment/beyond-mumbai-app web-server=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}
                            fi
                            
                            kubectl rollout status deployment/beyond-mumbai-app
                        '''
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}
                        echo "Deployment successful!"
                        echo "Getting service URL..."
                        kubectl get service beyond-mumbai-service
                    '''
                }
            }
        }
    }
}