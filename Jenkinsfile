pipeline {
    agent any

    environment {
        COMPARTMENT_OCID = credentials('oci-compartment-ocid')
        SUBNET_OCID      = credentials('oci-subnet-ocid')
        AVAIL_DOMAIN     = credentials('oci-availability-domain')
        KEY_FILE         = credentials('oci-config-file')
        BASE_IMAGE_OCID  = credentials('oci-base-image-ocid')
        GIT_REPO_URL     = 'https://github.com/Karthikbhatkarkada/simple-test-webapp.git'
        
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
                npm run build
                '''
            }
        }

        stage('Archive Binary') {
            steps {
                archiveArtifacts artifacts: 'testwebapp', fingerprint: true
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
                  -var base_image_ocid=${BASE_IMAGE_OCID} \
                  -var key_file=${KEY_FILE} \
                  -var binary_path=testwebapp \
                  ubuntu-simple-test-webapp.pkr.hcl
                '''
            }
        }
    }
}
