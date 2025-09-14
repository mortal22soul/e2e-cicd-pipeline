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
        PORT=8000

        MONGO_URI = "mongodb+srv://octopi.ynkkqtw.mongodb.net/planets"
        // MONGO_CREDS = credentials('mongo-creds') // wont work as we need username and password separately
        MONGO_USERNAME = credentials('mongo-user')
        MONGO_PASSWORD = credentials('mongo-pass')

        // SONAR_PROJECT_KEY = "solar-system"
        SONAR_SCANNER_HOME = tool name: 'sonar-7-2-0', type: 'hudson.plugins.sonar.SonarRunnerInstallation'

        DOCKERHUB = credentials('dockerhub-creds')
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

                        sh 'echo "Starting OWASP Dependency Check..."'
                        dependencyCheck additionalArguments: '''
                        --scan ./
                        --format "ALL"
                        --out ./
                        --prettyPrint "ALL"
                        --disableYarnAudit
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
                sh 'npm run test'
            }
        }

        stage('Code Coverage') {
            steps {
                // withCredentials([usernamePassword(credentialsId: 'mongo-creds', passwordVariable: 'MONGO_PASSWORD', usernameVariable: 'MONGO_USERNAME')]) {
                //     catchError(buildResult: 'SUCCESS', message: 'Oops! it will be fixed in future releases', stageResult: 'UNSTABLE') {
                //         sh 'npm run coverage'
                //     }
                // }
                catchError(buildResult: 'SUCCESS',
                            message: 'Oops! it will be fixed in future releases', 
                            stageResult: 'UNSTABLE') {
                        sh 'npm run coverage'
                }
            }
        }

        stage('SAST using Sonarqube'){
            steps{
                timeout(time: 60, unit: 'SECONDS') {
                    withSonarQubeEnv('sonarqube') {
                        sh 'echo "Starting SonarQube Analysis..."'
                        sh '''
                        $SONAR_SCANNER_HOME/bin/sonar-scanner \
                            -Dsonar.sources=app.js \
                            -Dsonar.token=$SONAR_TOKEN \
                            -Dsonar.javascript.lcov.reportPaths=./coverage/lcov.info
                        '''
                    }
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build'){
            steps{
                script{
                    sh 'docker build -t $DOCKERHUB_USR/solar-system:$GIT_COMMIT .'
                }
            }
        }

        stage('Image Scan with Trivy'){
            steps{
                sh '''
                trivy image $DOCKERHUB_USR/solar-system:$GIT_COMMIT \
                    --severity LOW,MEDIUM,HIGH \
                    --exit-code 0 \
                    --quiet \
                    --format json -o trivy-image-HIGH-results.json
                
                trivy image $DOCKERHUB_USR/solar-system:$GIT_COMMIT \
                    --severity CRITICAL \
                    --exit-code 1 \
                    --quiet \
                    --format json -o trivy-image-CRITICAL-results.json
                '''
            }
            post{
                always{
                    sh '''
                    trivy convert \
                    --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                    --output trivy-image-HIGH-results.html trivy-image-HIGH-results.json
                    
                    trivy convert \
                    --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                    --output trivy-image-CRITICAL-results.html trivy-image-CRITICAL-results.json
                    
                    trivy convert \
                    --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                    --output trivy-image-HIGH-results.xml trivy-image-HIGH-results.json

                    trivy convert \
                    --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                    --output trivy-image-CRITICAL-results.xml trivy-image-CRITICAL-results.json
                    '''
                }
            }
        }

        stage('Docker Push'){
            steps{
                withDockerRegistry(credentialsId: 'dockerhub-creds', url: "") {
                    sh 'docker push $DOCKERHUB_USR/solar-system:$GIT_COMMIT'
                }
            }
        }

        stage('Deploy - AWS EC2') {
            when {
                branch 'feature/*'
            }
            steps {
                script {
                    sshagent(['aws-ssh-ec2']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no ubuntu@43.204.141.86 "
                            if sudo docker ps -a | grep -q 'solar-system'; then
                                echo "Container found. Stopping..."
                                sudo docker stop "solar-system" && sudo docker rm "solar-system"
                                echo "Container stopped and removed."
                            fi

                            sudo docker run --name solar-system \\
                                -e MONGO_URI=$MONGO_URI \\
                                -e MONGO_USERNAME=$MONGO_USERNAME \\
                                -e MONGO_PASSWORD=$MONGO_PASSWORD \\
                                -e PORT=$PORT \\
                                -p $PORT:$PORT -d $DOCKERHUB_USR/solar-system:$GIT_COMMIT
                            "
                        '''
                    }
                }
            }
        }

        stage('Integration Testing - AWS EC2') {
            when {
                branch 'feature/*'
            }
            steps {
                // Optionally print environment variables to verify branch details
                sh 'printenv | grep -i branch'

                // Use the AWS Pipeline Steps plugin to set AWS credentials and region
                withAWS(credentials: 'AWS keys for dev-deploy', region: 'ap-south-1') {
                    sh '''
                        bash integration-testing-ec2.sh
                    '''
                }
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

            publishHTML([
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: './',
                reportFiles: 'trivy-image-CRITICAL-results.html',
                reportName: 'Trivy Image Critical Vul Report',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])

            publishHTML([
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: './',
                reportFiles: 'trivy-image-HIGH-results.html',
                reportName: 'Trivy Image High Vul Report',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])

            junit allowEmptyResults: true, testResults: 'test-results.xml'
            
            junit allowEmptyResults: true, keepProperties: true, testResults: 'dependency-check-junit.xml'
        }
    }
}