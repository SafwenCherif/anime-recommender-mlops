pipeline {
    agent any

    environment {
        VENV_DIR = 'venv'
        GCP_PROJECT = 'anime-recommnender-mlops'
        IMAGE_NAME = "anime-recommender"
        GOOGLE_APPLICATION_CREDENTIALS = "/home/jenkins/.config/gcloud/application_default_credentials.json"
        GKE_CLUSTER = "anime-recommender-cluster"
        GKE_REGION = "us-central1"
    }

    stages{

        stage("Cloning from Github...."){
            steps{
                script{
                    echo 'Cloning from Github...'
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/SafwenCherif/anime-recommender-mlops.git']])
                }
            }
        }

        stage("Setting up Virtual Environment and Installing dependencies"){
            steps{
                script{
                    echo 'Making a virtual environment...'
                    sh '''
                    python3 -m venv ${VENV_DIR}
                    . ${VENV_DIR}/bin/activate
                    pip install --upgrade pip
                    pip install -e .
                    '''
                }
            }
        }

        stage('Training Pipeline (with ADC mounted)'){
            steps{
                script{
                    echo 'Running Training Pipeline...'
                    sh '''
                    . ${VENV_DIR}/bin/activate
                    export PATH=$PATH:/usr/bin
                    export GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS}"
                    export GOOGLE_CLOUD_PROJECT="${GCP_PROJECT}"
                    python pipeline/training_pipeline.py
                    '''
                }
            }
        }

        stage('Build and Push Image to GCR'){
            steps{
                script{
                    echo 'Build and Push Image to GCR'
                    sh '''
                    export PATH=$PATH:/usr/bin
                    export CLOUDSDK_PYTHON=/usr/bin/python3

                    gcloud config set project ${GCP_PROJECT}
                    gcloud config set auth/credential_file_override ${GOOGLE_APPLICATION_CREDENTIALS}

                    gcloud auth configure-docker --quiet

                    docker build -t gcr.io/${GCP_PROJECT}/${IMAGE_NAME}:latest .
                    docker push gcr.io/${GCP_PROJECT}/${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploying to GKE Kubernetes'){
            steps{
                script{
                    echo 'Deploying to GKE...'
                    sh '''
                    export PATH=$PATH:/usr/bin
                    export CLOUDSDK_PYTHON=/usr/bin/python3
                    export GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS}"

                    gcloud config set project ${GCP_PROJECT}
                    gcloud config set auth/credential_file_override ${GOOGLE_APPLICATION_CREDENTIALS}
                    gcloud auth login --cred-file=${GOOGLE_APPLICATION_CREDENTIALS} || true

                    gcloud container clusters get-credentials ${GKE_CLUSTER} --region ${GKE_REGION}
                    kubectl apply --validate=false -f deployment.yaml
                    '''
                }
            }
        }
    }
}