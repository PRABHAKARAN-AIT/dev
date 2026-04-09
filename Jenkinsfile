pipeline {
    agent any

    options {
        retry(2)
    }

    environment {
        TEST_DEV_SERVER_IP     = '16.16.141.165'
        TEST_STAGING_SERVER_IP = '16.16.141.165'
        GITHUB_CREDENTIALS_ID  = 'github-creds'
        BW_CLIENT_ID           = credentials('BW_CLIENT_ID')
        BW_CLIENT_SECRET       = credentials('BW_CLIENT_SECRET')
        BW_ORG_ID              = credentials('BW_ORG_ID')
        BW_MASTER_PASSWORD     = credentials('BW_MASTER_PASSWORD')
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
        stage('Fetch Credentials from Bitwarden') {
            steps {
                sh '''
                    export BW_CLIENTID=$BW_CLIENT_ID
                    export BW_CLIENTSECRET=$BW_CLIENT_SECRET
                    bw login --apikey 2>/dev/null || true
                    export BW_SESSION=$(echo "$BW_MASTER_PASSWORD" | bw unlock --raw)
                    bw sync --session $BW_SESSION
                    DEV_USER=$(bw get username HQ_DEV_SSH --session $BW_SESSION)
                    DEV_PASS=$(bw get password HQ_DEV_SSH --session $BW_SESSION)
                    echo $DEV_USER > /tmp/dev_user.txt
                    echo $DEV_PASS > /tmp/dev_pass.txt
                '''
            }
        }
        stage('Deploy') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'development') {
                        sh '''
                            DEV_USER=$(cat /tmp/dev_user.txt)
                            DEV_PASS=$(cat /tmp/dev_pass.txt)
                            sshpass -p "$DEV_PASS" ssh -o StrictHostKeyChecking=no "$DEV_USER"@"$TEST_DEV_SERVER_IP" "set -e && cd /home/ec2-user/projects/dev && git fetch origin && git reset --hard origin/development && chmod +x deploy/development.sh && bash deploy/development.sh"
                        '''
                    } else if (env.BRANCH_NAME == 'release-candidate') {
                        sh '''
                            STAGING_USER=$(cat /tmp/dev_user.txt)
                            STAGING_PASS=$(cat /tmp/dev_pass.txt)
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