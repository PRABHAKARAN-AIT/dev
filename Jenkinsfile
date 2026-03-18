pipeline {
    agent any
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.image('docker:24-dind').inside('--privileged -v /var/run/docker.sock:/var/run/docker.sock') {
                        sh 'docker build -t my-app .'
                    }
                }
            }
        }
        stage('Run Container') {
            steps {
                script {
                    docker.image('docker:24-dind').inside('--privileged -v /var/run/docker.sock:/var/run/docker.sock') {
                        sh 'docker run -d -p 8080:8080 my-app'
                    }
                }
            }
        }
    }
}