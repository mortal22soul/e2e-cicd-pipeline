pipeline{
    agent any

    tools {
        nodejs 'node-24-6-0'  // So that jenkins recognises the npm installtion via the plugin
    }
    
    stages{
        stage('Prebuild'){
            steps{
                sh 'npm -v'
                sh 'node -v'
            }
        }
    }
}