pipeline{
    agent any

    tools {
        nodejs 'node-24-6-0'  // So that jenkins recognises the npm installtion via the plugin
    }
    
    stages{
        stage('Install Dependencies'){
            steps{
                sh 'npm install --no-audit'
            }
        }

        stage('Dependency Scans'){
            parallel{
                stage('NPM Dependency Audit'){
                    steps{
                        sh '''
                        npm audit --audit-level=critical
                        echo $?
                        '''
                    }
                }

                stage('OWASP Dependency Check'){
                    steps{
                        dependencyCheck additionalArguments: '''
                        --scan ./
                        --format "ALL"
                        --out ./
                        --prettyPrint "ALL"
                        ''', odcInstallation: 'owasp-dep-check-12-1-2'
                    }
                }
            }
        }
    }
}