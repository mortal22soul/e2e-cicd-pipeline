pipeline{
    agent any

    tools {
        nodejs 'node-24-6-0'
        // So that jenkins uses the npm installed via the plugin
    }

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')

        disableResume()
        disableConcurrentBuilds abortPrevious: true
    }

    environment {
        MONGO_URI = "mongodb+srv://octopi.ynkkqtw.mongodb.net/planets"
        PORT=9000
        // MONGO_CREDS = credentials('mongo-creds') // wont work as we need username and password separately
        MONGO_USERNAME = credentials('mongo-user')
        MONGO_PASSWORD = credentials('mongo-pass')

        SONAR_URL = "http://13.233.254.0:9000"
        SONAR_TOKEN = credentials('sonar-token')
        SONAR_PROJECT_KEY = "solar-system"
        SONAR_SCANNER_HOME = tool name: 'sonar-7-2-0', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
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
                    }   
                }
            }
        }

        stage('Unit Testing') {
            options{
                retry(2)
            }
            steps {
                // withCredentials([usernamePassword(credentialsId: 'mongo-creds', passwordVariable: 'MONGO_PASSWORD', usernameVariable: 'MONGO_USERNAME')]) {
                //     // sh 'npm run test -- --reporter spec'  // Add spec reporter for debugging
                    
                //     sh 'npm run test'
                // }
                sh 'npm run test -- --reporter spec'
            }
        }

        stage('Code Coverage') {
            steps {
                // withCredentials([usernamePassword(credentialsId: 'mongo-creds', passwordVariable: 'MONGO_PASSWORD', usernameVariable: 'MONGO_USERNAME')]) {
                //     catchError(buildResult: 'SUCCESS', message: 'Oops! it will be fixed in future releases', stageResult: 'UNSTABLE') {
                //         sh 'npm run coverage'
                //     }
                // }
                catchError(buildResult: 'SUCCESS', message: 'Oops! it will be fixed in future releases', stageResult: 'UNSTABLE') {
                        sh 'npm run coverage'
                }
            }
        }

        stage('SAST using Sonarqube'){
            steps{
                sh '''
                $SONAR_SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.host.url=$SONAR_URL \
                    -Dsonar.sources=app.js \
                    -Dsonar.token=$SONAR_TOKEN \
                    -Dsonar.projectKey=$SONAR_PROJECT_KEY \
                    -Dsonar.javascript.lcov.reportPaths=./coverage/lcov.info
                    '''
            }
        }

    }
    
    post {
        always {
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
            publishHTML([
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true, 
                        reportDir: 'coverage/lcov-report', 
                        reportFiles: 'index.html', 
                        reportName: 'Code Coverage HTML Report', 
                        reportTitles: '', 
                        useWrapperFileDirectly: true
                ])
            junit allowEmptyResults: true, testResults: 'test-results.xml'
            junit allowEmptyResults: true, keepProperties: true, testResults: 'dependency-check-junit.xml'
        }
    }
}