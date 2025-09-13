pipeline{
    agent any

    tools {
        nodejs 'node-24-6-0'
        // So that jenkins uses the npm installed via the plugin
    }

    environment {
        MONGO_URI = "mongodb+srv://octopi.ynkkqtw.mongodb.net/planets"
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
                        
                        dependencyCheckPublisher(
                                    failedTotalCritical: 4, 
                                    pattern: 'dependency-check-report.xml',
                                    stopBuild: true
                                )

                        junit allowEmptyResults: true, keepProperties: true, testResults: 'dependency-check-junit.xml'

                        publishHTML([
                            allowMissing: true,
                            alwaysLinkToLastBuild: true,
                            keepAll: true,
                            reportDir: '.',
                            reportFiles: 'dependency-check-jenkins.html',
                            reportName: 'Dependency Check HTML',
                            reportTitles: '',
                            useWrapperFileDirectly: true
                        ])
                    }   
                }
            }
        }

        stage('Unit Testing') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'mongo-creds', passwordVariable: 'MONGO_PASSWORD', usernameVariable: 'MONGO_USERNAME')]) {
                    sh 'echo "Running tests..."'
                    sh 'npm run test -- --reporter spec'  // Add spec reporter for debugging
                    junit allowEmptyResults: true, testResults: 'test-results.xml'
                }
            }
        }
    }
}