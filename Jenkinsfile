pipeline {
    agent any

    environment {
        COMPARTMENT_OCID = credentials('oci-compartment-ocid')
        SUBNET_OCID      = credentials('oci-subnet-ocid')
        AVAIL_DOMAIN     = credentials('oci-availability-domain')
        GIT_REPO_URL     = 'https://github.com/<your-username>/<your-repo>.git'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${env.GIT_REPO_URL}"
            }
        }

        stage('Build Binary') {
            steps {
                sh '''
                npm install
                npm install pkg --save-dev
                npx pkg . --targets node20-linux-x64 --output webapp
                '''
            }
        }

        stage('Archive Binary') {
            steps {
                archiveArtifacts artifacts: 'webapp', fingerprint: true
            }
        }

        stage('Packer Build') {
            steps {
                sh '''
                packer init .
                packer build \
                  -var compartment_ocid=${COMPARTMENT_OCID} \
                  -var subnet_ocid=${SUBNET_OCID} \
                  -var availability_domain=${AVAIL_DOMAIN} \
                  -var binary_path=webapp \
                  ubuntu-nodeapp.pkr.hcl
                '''
            }
        }
    }
}
