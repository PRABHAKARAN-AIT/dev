pipeline {
    agent any

    options {
        retry(2)
    }

    environment {
        TEST_DEV_SERVER_IP     = '13.50.239.205'
        TEST_STAGING_SERVER_IP = '13.50.239.205'
        GITHUB_CREDENTIALS_ID  = 'github-creds'
        BW_PASSWORD            = credentials('BW_PASSWORD')
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {
        stage('Pipeline Started') {
            steps { echo 'CI/CD Pipeline Triggered' }
        }
        stage('Checkout Code') {
            steps {
                git(url: 'https://github.com/PRABHAKARAN-AIT/dev.git',
                    branch: env.BRANCH_NAME ?: 'development',
                    credentialsId: env.GITHUB_CREDENTIALS_ID)
            }
        }
        stage('Deploy') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'development') {
                        sh '''
                            export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)
                            DEV_USER=$(bw get username HQ_DEV_SSH --session $BW_SESSION)
                            DEV_PASS=$(bw get password HQ_DEV_SSH --session $BW_SESSION)
                            sshpass -p "$DEV_PASS" ssh -o StrictHostKeyChecking=no "$DEV_USER"@"$TEST_DEV_SERVER_IP" "set -e && cd /home/ec2-user/projects/dev && git fetch origin && git reset --hard origin/development && chmod +x deploy/development.sh && bash deploy/development.sh"
                        '''
                    } else if (env.BRANCH_NAME == 'release-candidate') {
                        sh '''
                            export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)
                            STAGING_USER=$(bw get username HQ_DEV_SSH --session $BW_SESSION)
                            STAGING_PASS=$(bw get password HQ_DEV_SSH --session $BW_SESSION)
                            sshpass -p "$STAGING_PASS" ssh -o StrictHostKeyChecking=no "$STAGING_USER"@"$TEST_STAGING_SERVER_IP" "set -e && cd /home/ec2-user/projects/dev && git fetch origin && git reset --hard origin/release-candidate && chmod +x deploy/staging.sh && bash deploy/staging.sh"
                        '''
                    }
                }
            }
        }
    }
    post {
        success  { echo 'Deployment completed successfully!' }
        failure  { echo 'Deployment failed. Check Jenkins logs.' }
        always   { cleanWs() }
    }
}