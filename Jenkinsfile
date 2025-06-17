// pipeline {
//     agent any

//     environment {
//         EC2_HOST = credentials('ec2-host')              // e.g., 13.235.123.45
//         EC2_USER = credentials('ec2-user')              // e.g., ubuntu or ec2-user
//         EC2_SSH_PORT = credentials('ec2-ssh-port')      // usually 22
//         EC2_PROJECT_DIR = credentials('ec2-project-dir')// e.g., /home/ubuntu/foodsite
//     }

//     stages {
//         stage('Checkout Code') {
//             steps {
//                 checkout scm
//             }
//         }

//         stage('Write SSH Key') {
//             steps {
//                 withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY_FILE')]) {
//                     sh '''
//                     cp $KEY_FILE ec2_key.pem
//                     chmod 600 ec2_key.pem
//                     '''
//                 }
//             }
//         }

//         stage('Sync Project to EC2') {
//             steps {
//                 sh '''
//                 rsync -avz --exclude='.env' -e "ssh -i ec2_key.pem -p $EC2_SSH_PORT -o StrictHostKeyChecking=no" \
//                   ./foodsite/ $EC2_USER@$EC2_HOST:$EC2_PROJECT_DIR/
//                 '''
//             }
//         }

//         stage('SSH into EC2 and Deploy') {
//             steps {
//                 sh '''
//                 ssh -i ec2_key.pem -p $EC2_SSH_PORT -o StrictHostKeyChecking=no \
//                   $EC2_USER@$EC2_HOST << 'EOF'

//                   set -e

//                   cd $EC2_PROJECT_DIR

//                   echo "Activating and installing requirements..."
//                   source venv/bin/activate
//                   venv/bin/pip install -r requirements.txt

//                   echo "Applying migrations..."
//                   venv/bin/python manage.py migrate

//                   echo "Exporting settings..."
//                   export DJANGO_SETTINGS_MODULE=foodsite.settings

//                   echo "Restarting services..."
//                   sudo systemctl daemon-reload
//                   sudo systemctl restart foodsite
//                   sudo systemctl restart nginx

//                   echo "✅ Deployment complete"
//                 EOF
//                 '''
//             }
//         }
//     }
//

pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME=credentials('docker-user')
        DOCKERHUB_PASSWORD=credentials('docker-pass')
        JUMP_HOST = credentials('jump-host')
        JUMP_USER = credentials('jump-user')
        PRIVATE_HOST = credentials('private-host')
        PRIVATE_USER = credentials('private-user')
        PRIVATE_PROJECT_DIR = credentials('private-project-dir')
        EC2_SSH_PORT = credentials('ec2-ssh-port')
        WEBHOOK=credentials('webhook')
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('login dockerhub'){
          steps {
              sh '''
               echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
               '''
          }
       }
        stage('docker image tag'){
            steps{
                script{
                    def tag = new Date().format("yyyyMMdd-HHmmss")
                    env.IMAGE_TAG = tag
                }
            }
        }
        stage('docker build and push image')
        {
            steps{
                sh 'chmod +x ./foodsite/scripts/*.sh && ./foodsite/scripts/docker_build_push.sh $DOCKERHUB_USERNAME $IMAGE_TAG'
            }
        }
    

        stage('Write SSH Keys') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'jump-ssh-key', keyFileVariable: 'JUMP_KEY_FILE'),
                    sshUserPrivateKey(credentialsId: 'private-ec2-key', keyFileVariable: 'PRIVATE_KEY_FILE')
                ]) {
                    sh '''
                    cp $JUMP_KEY_FILE jump_key.pem
                    chmod 600 jump_key.pem

                    cp $PRIVATE_KEY_FILE private-ec2.pem
                    chmod 600 private-ec2.pem
                    '''
                }
            }
        }
      
        stage('Send Code to Jump Server') {
            steps {
                sh './foodsite/scripts/ssh_deploy.sh jump_key.pem  private-ec2.pem $JUMP_USER $JUMP_HOST $PRIVATE_USER $PRIVATE_HOST $PRIVATE_PROJECT_DIR $DOCKERHUB_USERNAME $DOCKERHUB_PASSWORD $IMAGE_TAG'
            }
        }
    }
    post {
        success {
           withCredentials([string(credentialsId: 'webhook', variable: 'WEBHOOK')]) {
       script{ def message = [
        text: "✅ Jenkins Deployment Successful for job: ${env.JOB_NAME} [#${env.BUILD_NUMBER}](${env.BUILD_URL})"
    ]
    writeFile file: 'payload.json', text: groovy.json.JsonOutput.toJson(message)

    sh '''
        curl -X POST -H "Content-Type: application/json" \
        -d @payload.json \
        "$WEBHOOK"
    '''
        }}}

        failure {
            script {
                 def message = [
        text: "✅ Jenkins Deployment Successful for job: ${env.JOB_NAME} [#${env.BUILD_NUMBER}](${env.BUILD_URL})"
    ]
    def jsonMessage = groovy.json.JsonOutput.toJson(message).replace("'", "'\\''")

    sh """
        curl -X POST -H 'Content-Type: application/json' \
        -d '${jsonMessage}' \
        "$WEBHOOK"
    """
            }
        }
    }

}
