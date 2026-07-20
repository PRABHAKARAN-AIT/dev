pipeline {
    agent any

    options {
        retry(2)
    }

    environment {
        // Development Server
        TEST_DEV_SERVER_IP = '16.16.70.229'

        // Staging Server
        TEST_STAGING_SERVER_IP = '16.16.70.229'

        // Jenkins Credentials
        GITHUB_CREDENTIALS_ID = 'github-creds'
        SSH_CREDENTIALS_ID    = 'ec2-ssh-key'

        // Bitwarden Credentials
        BW_CLIENT_ID       = credentials('BW_CLIENT_ID')
        BW_CLIENT_SECRET   = credentials('BW_CLIENT_SECRET')
        BW_MASTER_PASSWORD = credentials('BW_MASTER_PASSWORD')
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {

        stage('Pipeline Started') {
            steps {
                echo "CI/CD Pipeline Triggered"
            }
        }

        stage('Checkout Code') {
            steps {
                git(
                    url: 'https://github.com/PRABHAKARAN-AIT/dev.git',
                    branch: env.BRANCH_NAME ?: 'development',
                    credentialsId: GITHUB_CREDENTIALS_ID
                )
            }
        }

        stage('Bitwarden Login') {
            steps {
                sh '''
                    export BW_CLIENTID=$BW_CLIENT_ID
                    export BW_CLIENTSECRET=$BW_CLIENT_SECRET

                    bw login --apikey 2>/dev/null || true

                    export BW_SESSION=$(echo "$BW_MASTER_PASSWORD" | bw unlock --raw)

                    bw sync --session "$BW_SESSION"
                '''
            }
        }

        stage('Deploy') {
            steps {
                script {

                    if (env.BRANCH_NAME == 'development') {

                        sshagent([SSH_CREDENTIALS_ID]) {

                            sh """
                                ssh -o StrictHostKeyChecking=no ubuntu@${TEST_DEV_SERVER_IP} '
                                    set -e

                                    cd /home/ubuntu/projects/dev

                                    git fetch origin
                                    git reset --hard origin/development

                                    chmod +x deploy/development.sh

                                    bash deploy/development.sh
                                '
                            """
                        }

                    } else if (env.BRANCH_NAME == 'release-candidate') {

                        sshagent([SSH_CREDENTIALS_ID]) {

                            sh """
                                ssh -o StrictHostKeyChecking=no ubuntu@${TEST_STAGING_SERVER_IP} '
                                    set -e

                                    cd /home/ubuntu/projects/dev

                                    git fetch origin
                                    git reset --hard origin/release-candidate

                                    chmod +x deploy/staging.sh

                                    bash deploy/staging.sh
                                '
                            """
                        }

                    } else {

                        echo "No deployment configured for branch: ${env.BRANCH_NAME}"

                    }
                }
            }
        }
    }

    post {

        success {
            echo "Deployment completed successfully!"
        }

        failure {
            echo "Deployment failed. Check Jenkins logs."
        }

        always {
            cleanWs()
        }
    }
}