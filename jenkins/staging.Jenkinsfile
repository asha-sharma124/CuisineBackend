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


@Library('my-lib@main') _

pipeline {
    agent any
    stages {
        stage('Test Notification') {
            steps {
                script {
            google-chat()
        }
            }
        }
    }
}

