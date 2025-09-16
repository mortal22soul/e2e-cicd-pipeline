@Library('jenkins-shared-libs@feature/trivyScan') _

pipeline{
    agent any

    tools {
        nodejs 'node-24-6-0'
        // So that jenkins uses the npm installed via the plugin
    }

    options {
        // timestamps()
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

        GITEA_USER = "mortal22soul"
        GITEA_TOKEN = credentials('a0b327fd-b6af-4d2e-a203-2be525f30e9c') // for pushing to gitops repo

        DOCKERHUB = credentials('dockerhub-creds')
        // here we get username and password both and later we can separate them using $DOCKERHUB_USR and $DOCKERHUB_PSW
    }
    
    stages{
        stage('Install Dependencies'){
            steps{
                sh 'npm install --no-audit --package-lock'
            }
        }

        stage('Dependency Scans'){
            parallel{
                stage('NPM Dependency Audit'){
                    steps{
                        sh '''
                        npm audit --audit-level=critical || echo $?
                        '''
                    }
                }

                // stage('OWASP Dependency Check'){
                //     steps{

                //         sh 'echo "Starting OWASP Dependency Check..."'
                        
                //         dependencyCheck additionalArguments: '''
                //         --scan ./
                //         --format "ALL"
                //         --out ./
                //         --prettyPrint "ALL"
                //         --disableYarnAudit
                //         ''', odcInstallation: 'owasp-dep-check-12-1-2'
                        
                //         dependencyCheckPublisher(
                //                     failedTotalCritical: 4, 
                //                     pattern: 'dependency-check-report.xml',
                //                     stopBuild: true
                //         )
                //     }   
                // }
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

        // stage('SAST using Sonarqube'){
        //     steps{
        //         timeout(time: 60, unit: 'SECONDS') {
        //             withSonarQubeEnv('sonarqube') {
        //                 sh 'echo "Starting SonarQube Analysis..."'
        //                 sh '''
        //                 $SONAR_SCANNER_HOME/bin/sonar-scanner \
        //                     -Dsonar.projectKey=solar-system \
        //                     -Dsonar.sources=app.js \
        //                     -Dsonar.javascript.lcov.reportPaths=./coverage/lcov.info
        //                 '''
        //             }
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

        stage('Docker Build'){
            steps{
                script{
                    sh 'docker build -t $DOCKERHUB_USR/solar-system:$GIT_COMMIT .'
                }
            }
        }

        stage('Image Scan with Trivy'){
            steps{
                script{
                    trivyScan.vulnerabilityScan("$DOCKERHUB_USR/solar-system:$GIT_COMMIT")
                }
            }
            post{
                always{
                    script{
                        trivyScan.reportsConverter()
                    }
                }
            }
        }

        // stage('Docker Push'){
        //     steps{
        //         withDockerRegistry(credentialsId: 'dockerhub-creds', url: "") {
        //             sh 'docker push $DOCKERHUB_USR/solar-system:$GIT_COMMIT'
        //         }
        //     }
        // }

        // stage('Deploy - AWS EC2') {
        //     when {
        //         branch 'feature/*'
        //     }
        //     steps {
        //         script {
        //             sshagent(['aws-ssh-ec2']) {
        //                 sh '''
        //                     ssh -o StrictHostKeyChecking=no ubuntu@65.0.87.74 "
        //                     if sudo docker ps -a | grep -q 'solar-system'; then
        //                         echo "Container found. Stopping..."
        //                         sudo docker stop "solar-system" && sudo docker rm "solar-system"
        //                         echo "Container stopped and removed."
        //                     fi

        //                     sudo docker run --name solar-system \\
        //                         -e MONGO_URI=$MONGO_URI \\
        //                         -e MONGO_USERNAME=$MONGO_USERNAME \\
        //                         -e MONGO_PASSWORD=$MONGO_PASSWORD \\
        //                         -e PORT=$PORT \\
        //                         -p $PORT:$PORT -d $DOCKERHUB_USR/solar-system:$GIT_COMMIT
        //                     "
        //                 '''
        //             }
        //         }
        //     }
        // }

        // stage('Integration Testing - AWS EC2') {
        //     when {
        //         branch 'feature/*'
        //     }
        //     steps {
        //         // Optionally print environment variables to verify branch details
        //         sh 'printenv | grep -i branch'

        //         // Use the AWS Pipeline Steps plugin to set AWS credentials and region
        //         withAWS(credentials: 'AWS keys for dev-deploy', region: 'ap-south-1') {
        //             sh '''
        //                 bash integration-testing-ec2.sh
        //             '''
        //         }
        //     }
        // }

        // stage('K8s Update Image Tag') {
        //     when {
        //         branch 'PR*' // only if the branch starts with PR
        //     }
        //     steps {
        //         sh 'git clone -b main http://13.233.254.0:3000/mortal22soul/solar-system-gitops-argocd'
        //         dir('solar-system-gitops-argocd/kubernetes') {
        //             sh '''
        //                 ##### Replace Docker Tag #####
        //                 git checkout main
        //                 git checkout -b feature-$BUILD_ID
        //                 sed -i "s#$DOCKERHUB_USR/solar-system:.*#$DOCKERHUB_USR/solar-system:$GIT_COMMIT#g" deployment.yml
        //                 cat deployment.yml


        //                 ##### Commit and Push to Feature Branch #####
        //                 git config --global user.email "metalmoshpit@outlook.com"
        //                 git config --global user.name "mortal22soul"
        //                 git remote set-url origin http://$GITEA_TOKEN@13.233.254.0:3000/mortal22soul/solar-system-gitops-argocd
        //                 git add .
        //                 git commit -am "Updated docker image"
        //                 git push -u origin feature-$BUILD_ID
        //             '''
        //         }
        //     }
        // }

        // stage('K8S - Raise PR') {
        //     steps{
        //         sh """
        //             curl -X 'POST' \
        //             'http://13.233.254.0:3000/api/v1/repos/mortal22soul/solar-system-gitops-argocd/pulls' \
        //             -H 'accept: application/json' \
        //             -H 'Authorization: token 7549d7df9ff403021eade699584ecff1ebdb9285' \
        //             -H 'Content-Type: application/json' \
        //             -d '{
        //                 "assignee": "mortal22soul",
        //                 "assignees": [
        //                     "mortal22soul"
        //                 ],
        //                 "base": "main",
        //                 "body": "Updated docker image in deployment manifest",
        //                 "head": "feature-$BUILD_ID",
        //                 "title": "Updated Docker Image"
        //             }'
        //         """
        //     }
        // }
        
        // stage('App Deployed') {
        //     when {
        //         branch 'PR*'
        //     }
        //     steps {
        //         timeout(time: 1, unit: 'DAYS') {
        //             input message: 'Is the PR merged and is the Argo CD application synced?', ok: 'Yes, PR merged & Argo CD synced'
        //         }
        //     }
        // }

        // stage('DAST - OWASP ZAP') {
        //     when {
        //         branch 'PR*'
        //     }
        //     steps {
        //         sh '''
        //         ##### REPLACE below with Kubernetes http://IP_Address:30000/api-docs/ #####
        //         chmod 777 $(pwd)
        //         docker run -v $(pwd):/zap/wrk/:rw -t zaproxy/zap-stable zap.sh \
        //         -t http://43.205.242.235:30000/api-docs/ \
        //         -f openapi \
        //         -r zap_report.html \
        //         -w zap_report.md \
        //         -J zap_json_report.json \
        //         -x zap_xml_report.xml \
        //         -c zap_ignore_rules.conf
        //         '''
        //     }
        // }

        // stage('Upload - AWS S3') {
        //     when {
        //         anyOf {
        //             branch 'PR*'
        //             branch 'feature*'
        //         }
        //     }
        //     steps {
        //         sh '''
        //             mkdir reports-$BUILD_ID
        //             cp -rf coverage/ reports-$BUILD_ID/
        //             cp dependency* test-results.xml trivy*.* zap*.* reports-$BUILD_ID/
        //         '''
        //         withAWS(credentials: 'aws-s3-ec2-lambda-creds', region: 'us-east-2') {
        //             s3Upload(
        //                 file: "reports-$BUILD_ID",
        //                 bucket: 'solar-system-jenkins-reports-bucket',
        //                 path: "jenkins-$BUILD_ID/"
        //             )
        //         }
        //     }
        // }

        // stage('Deploy to Prod?') {
        //     when {
        //         branch 'main'
        //     }
        //     steps {
        //         timeout(time: 1, unit: 'DAYS') {
        //             input message: 'Deploy to Production?', ok: 'YES! Let us try this on Production', submitter: 'admin'
        //         }
        //     }
        // }

        // stage('Lambda -- S3 Upload & Deploy') {
        //     when {
        //         branch 'main'
        //     }
        //     steps {
        //         withAWS(credentials: 'AWS keys for dev-deploy', region: 'ap-south-1') {
        //             sh '''
        //                 tail -5 app.js
        //                 echo "**********************************************************"
        //                 sed -i "s|/app\\.listen(3000|/||" app.js
        //                 sed -i "s|/module.exports = app;|/|g" app.js
        //                 sed -i "s|^|/module.exports.handler|module.exports.handler|" app.js
        //                 echo "**********************************************************"
        //                 tail -5 app.js
        //             '''
        //             sh '''
        //                 zip -qr solar-system-lambda-$BUILD_ID.zip app* package* index.html node*
        //                 ls -ltr solar-system-lambda-$BUILD_ID.zip
        //             '''
        //             s3Upload {
        //                 file: "solar-system-lambda-${BUILD_ID}.zip",
        //                 bucket: "solar-system-lambda-bucket"
        //             }
        //             sh """
        //                 aws lambda update-function-code \
        //                 --function-name solar-system-function \
        //                 --s3-bucket solar-system-lambda-bucket \
        //                 --s3-key solar-system-lambda-$BUILD_ID.zip
        //             """
        //             sh """
        //                 aws lambda update-function-configuration \
        //                 --function-name solar-system-function \
        //                 --environment '{"Variables":{"MONGO_USERNAME":"${MONGO_USERNAME}","MONGO_PASSWORD":"${MONGO_PASSWORD}","MONGO_URI":"${MONGO_URI}"}}'
        //             """
        //         }
        //     }
        // }

        // stage('Lambda - Invoke Function') {
        //     when {
        //         branch 'main'
        //     }
        //     steps {
        //         withAWS(credentials: 'AWS keys for dev-deploy', region: 'ap-south-1') {
        //             sh '''
        //                 sleep 30s
        //                 function_url_data=$(aws lambda get-function-url-config --function-name solar-system-function)
        //                 function_url=$(echo $function_url_data | jq -r '.FunctionUrl | sub("/$"; "")')
        //                 curl -Is $function_url/live | grep -i "200 OK"
        //             '''
        //         }
        //     }
        // }
    }

        post {
            always {

                slackNotification(currentBuild.currentResult)

                // Clean up the manifest repository to avoid clone conflicts in subsequent runs.
                // script {
                //     if (fileExists('solar-system-gitops-argocd')) {
                //         sh 'rm -rf solar-system-gitops-argocd'
                //     }
                // }

                // publishHTML([
                //     allowMissing: true,
                //     alwaysLinkToLastBuild: true,
                //     keepAll: true,
                //     reportDir: '.',
                //     reportFiles: 'dependency-check-jenkins.html',
                //     reportName: 'Dependency Check HTML',
                //     reportTitles: '',
                //     useWrapperFileDirectly: true
                // ])

                // publishHTML([
                //     allowMissing: true,
                //     alwaysLinkToLastBuild: true,
                //     keepAll: true, 
                //     reportDir: 'coverage/lcov-report', 
                //     reportFiles: 'index.html', 
                //     reportName: 'Code Coverage HTML Report', 
                //     reportTitles: '', 
                //     useWrapperFileDirectly: true
                // ])

                // publishHTML([
                //     allowMissing: true,
                //     alwaysLinkToLastBuild: true,
                //     keepAll: true,
                //     reportDir: './',
                //     reportFiles: 'trivy-image-CRITICAL-results.html',
                //     reportName: 'Trivy Image Critical Vul Report',
                //     reportTitles: '',
                //     useWrapperFileDirectly: true
                // ])

                // publishHTML([
                //     allowMissing: true,
                //     alwaysLinkToLastBuild: true,
                //     keepAll: true,
                //     reportDir: './',
                //     reportFiles: 'trivy-image-HIGH-results.html',
                //     reportName: 'Trivy Image High Vul Report',
                //     reportTitles: '',
                //     useWrapperFileDirectly: true
                // ])

                // publishHTML([allowMissing: true,
                //     alwaysLinkToLastBuild: true,
                //     keepAll: true,
                //     reportDir: './',
                //     reportFiles: 'zap_report.html',
                //     reportName: 'DAST - OWASP ZAP Report',
                //     reportTitles: '',
                //     useWrapperFileDirectly: true
                // ])

                // junit allowEmptyResults: true, stdioRetention: '', testResults: 'test-results.xml'
                // junit allowEmptyResults: true, stdioRetention: '', testResults: 'dependency-check-junit.xml'
                // junit allowEmptyResults: true, stdioRetention: '', testResults: 'zap_xml_report.xml'
                junit allowEmptyResults: true, stdioRetention: '', testResults: 'trivy-image-CRITICAL-results.xml'
                junit allowEmptyResults: true, stdioRetention: '', testResults: 'trivy-image-HIGH-results.xml'
        }
    }
}