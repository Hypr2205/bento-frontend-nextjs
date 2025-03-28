pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-southeast-1'
        ECR_REPO = 'bento-frontend'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        MANIFEST_REPO = 'https://github.com/Hypr2205/bento-frontend-manifest.git'
        MANIFEST_BRANCH = 'main'
        MANIFEST_DIR = 'k8s'
    }
    
    stages {
        stage('Configure credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID')
                ]) {
                    sh """
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region $AWS_REGION
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    """
                }
            }
        }
        stage('Checkout repo') {
            steps {
                checkout scm
            }
        }
        // stage('install dependencies') {
        //     steps {
        //         sh "npm install"
        //     }
        // }
        // stage('Snyk code scan') {
        //     steps {
        //         echo 'Code testing'
        //         snykSecurity(
        //             snykInstallation: 'snyk@latest',
        //             snykTokenId: 'snyk',
        //             monitorProjectOnBuild: true
        //         )
        //     }
        // }
        stage('Build image') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID')
                ]) {
                    sh """
                        docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                        docker tag ${ECR_REPO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                    """
                }
            }
        }
        stage('Push image to ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID')
                ]) {
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
                }
            }
        }
        stage('Update k8s deployment spec') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID')
                ]) {
                    sh """
                        rm -rf ${MANIFEST_DIR}
                        git clone -b ${MANIFEST_BRANCH} ${MANIFEST_REPO} ${MANIFEST_DIR}
                        cd ${MANIFEST_DIR}
                        sed -i 's|image: .*bento-frontend:.*|image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}|' ./frontend/deployment.yaml
                        git add .
                        git commit -m 'Update deployment image to ${IMAGE_TAG}'
                        git push origin ${MANIFEST_BRANCH}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Build and push successful!"
        }
        failure {
            echo "Build failed!"
        }
    }
}