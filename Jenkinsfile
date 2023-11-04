pipeline {
    agent {
        label 'gcp-vm'
    }
    stages {
        stage("Checkout code") {
            steps {
                checkout scm
                }
            }
        stage('Setup cluster credentials') {
          steps {
              sh 'gcloud container clusters get-credentials cluster --zone us-east1-b --project amin-final --internal-ip'
          }
        }
        
        stage('Deploy Mongo DB to GKE') {
          steps {
              sh 'kubectl apply -f backend'
          }
        }
        
        stage('sleep till mongodb is ready') {
          steps {
              sh 'sleep 60'
          }
        }
        
        stage('Deploy Node App to GKE') {
          steps {
              sh 'kubectl apply -f frontend'
          }
        }
        
        stage('Echo Kubernetes Load balancer Service External IP') {
            steps {
                sh 'sleep 60'
                sh 'kubectl get svc -n frontend'
            }
        }
    }    
}
