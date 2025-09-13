pipeline{
    agent any
    stages{
        stage('Prebuild'){
            steps{
                sh 'npm -v'
                sh 'node -v'
            }
        }
        stage('Build'){
            steps{
                echo 'Building...'
            }
        }
        stage('Test'){
            steps{
                echo 'Testing...'
            }
        }
        stage('Deploy'){
            steps{
                echo 'Deploying...'
            }
        }
    }
}