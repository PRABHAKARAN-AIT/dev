pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        stage('Run Container') {
            steps {
                sh 'docker stop my-app || true'
                sh 'docker rm my-app || true'
                sh 'docker run -d -p 3000:3000 --name my-app my-app'
            }
        }
    }
}