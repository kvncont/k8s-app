pipeline{
    agent any

    environment {
        DB_USER_CREDENTIALS = credentials("MY_DB_USER") // MY_DB_USER is a secret stored in the Jenkins credential store
        DB_PASS_CREDENTIALS = credentials("MY_DB_PASS") // MY_DB_PASS is a secret stored in the Jenkins credential store
        REGISTRY_CREDENTIALS = credentials("MY_REGISTRY") // MY_REGISTRY is a secret stored in the Jenkins credential store
        REGISTRY = "crpersonal.azurecr.io"
        IMAGE_NAME = "k8s-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        IMAGE= "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages{
        stage("Build"){
            steps{
                sh "docker build --progress=plain -t $IMAGE ."
            }
        }
        stage("Scan Vulnerabilities"){
            steps{
                sh "grype $IMAGE --fail-on medium"
            }
        }
        stage("Push"){
            when { branch "main" }
            steps{
                sh "docker login -u $REGISTRY_CREDENTIALS_USR -p $REGISTRY_CREDENTIALS_PWD"
                sh "docker push $IMAGE"
            }
        }
        stage("Deploy k8s"){
            when { branch "main" }
            steps{
                sh "kubectl create namespace k8s | true"
                sh "kubectl delete secret k8s-app-secret -n k8s | true"
                sh "kubectl create secret generic k8s-app-secret --from-literal=database-user=$DB_USER_CREDENTIALS --from-literal=database-pass=$DB_PASS_CREDENTIALS -n k8s"
                sh "kubectl apply -f k8s/dev/. -n k8s"
            }
        }
        stage("Test app"){
            when { branch "main" }
            steps{
                sh "./mvnw clean test -Dtest=*IntegrationTest"
            }
            post{
                failure{
                    echo "Rolling back deployment"
                    sh "kubectl rollout undo deployment/k8s-app-deployment -n k8s"
                }
            }
        }
    }
    post{
        always{
            echo "========always========"
        }
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}