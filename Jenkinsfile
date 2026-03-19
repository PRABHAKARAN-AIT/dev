#!/usr/bin/env groovy

pipeline {
    agent any

    options {
        retry(2)
    }

    environment {
        TEST_DEV_SERVER_IP     = '107.23.154.141'
        TEST_STAGING_SERVER_IP = '54.167.75.234'
        GITHUB_CREDENTIALS_ID  = 'github-creds'
        HQ_DEV_CRED            = 'HQ_DEV_SSH'
        HQ_STAGING_CRED        = 'HQ_STAGING_SSH'
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
                        withCredentials([usernamePassword(
                            credentialsId: env.HQ_DEV_CRED,
                            usernameVariable: 'HQ_DEV_USER',
                            passwordVariable: 'HQ_DEV_PASS')]) {
                            sh '''
                                sshpass -p "$HQ_DEV_PASS" \
                                ssh -o StrictHostKeyChecking=no \
                                "$HQ_DEV_USER"@"$TEST_DEV_SERVER_IP" "
                                    set -e &&
                                    cd /home/ubuntu/projects/dev &&
                                    git fetch origin &&
                                    git reset --hard origin/development &&
                                    chmod +x deploy/development.sh &&
                                    bash deploy/development.sh
                                "
                            '''
                        }
                    } else if (env.BRANCH_NAME == 'release-candidate') {
                        withCredentials([usernamePassword(
                            credentialsId: env.HQ_STAGING_CRED,
                            usernameVariable: 'HQ_STAGING_USER',
                            passwordVariable: 'HQ_STAGING_PASS')]) {
                            sh '''
                                sshpass -p "$HQ_STAGING_PASS" \
                                ssh -o StrictHostKeyChecking=no \
                                "$HQ_STAGING_USER"@"$TEST_STAGING_SERVER_IP" "
                                    set -e &&
                                    cd /home/ubuntu/projects/dev &&
                                    git fetch origin &&
                                    git reset --hard origin/release-candidate &&
                                    chmod +x deploy/staging.sh &&
                                    bash deploy/staging.sh
                                "
                            '''
                        }
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