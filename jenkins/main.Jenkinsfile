// pipeline {
//     agent any

//     environment {
//         EC2_HOST = credentials('ec2-host')              
//         EC2_USER = credentials('ec2-user')              
//         EC2_SSH_PORT = credentials('ec2-ssh-port')     
//         EC2_PROJECT_DIR = credentials('ec2-project-dir')
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

//   stage('SSH into EC2 and Deploy') {
//     steps {
//         sh '''
//         ssh -i ec2_key.pem -p $EC2_SSH_PORT -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST <<EOF
// set -xe

// cd ~/backend/foodsite || exit 1
// ls

// echo "Removing old venv..."
// rm -rf venv

// echo "Creating new venv..."
// which python3.12
// python3.12 --version
// python3.12 -m venv venv

// echo "Installing requirements..."
// venv/bin/pip install -r requirements.txt

// echo "Running migrations..."
// venv/bin/python manage.py migrate

// echo "Restarting services..."
// sudo systemctl daemon-reload
// sudo systemctl restart foodsite
// sudo systemctl restart nginx

// echo "✅ Deployment complete"
// EOF
//         '''
//     }
// }
//     }}

pipeline {
    agent any

    environment {
        JUMP_HOST = credentials('jump-host')
        JUMP_USER = credentials('jump-user')
        PRIVATE_HOST = credentials('private-host')
        PRIVATE_USER = credentials('private-user')
        PRIVATE_PROJECT_DIR = credentials('private-project-dir')
        EC2_SSH_PORT = credentials('ec2-ssh-port')
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
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
                sh '''
                echo "Sending code to Jump Server..."
                rsync -avz --exclude='.env' \
                -e 'ssh -o ProxyCommand="ssh -i jump_key.pem -o StrictHostKeyChecking=no $JUMP_USER@$JUMP_HOST  -W %h:%p" \
                -i private-ec2.pem -o StrictHostKeyChecking=no' ./foodsite/  $PRIVATE_USER@$PRIVATE_HOST:$PRIVATE_PROJECT_DIR/
                '''
            }
        }

        stage('SSH from Jump to Private and Deploy') {
            steps {
                sh '''
                echo " Deploying from Jump Server to Private EC2..."



                ssh -o ProxyCommand="ssh -i jump_key.pem -o StrictHostKeyChecking=no $JUMP_USER@$JUMP_HOST  -W %h:%p" \
                -i private-ec2.pem -o StrictHostKeyChecking=no  $PRIVATE_USER@$PRIVATE_HOST << EOF
set -xe
cd $PRIVATE_PROJECT_DIR


echo " Installing dependencies..."
venv/bin/pip install -r requirements.txt

echo " Running Django migrations..."
venv/bin/python manage.py migrate

echo "Restarting services..."
sudo systemctl daemon-reload
sudo systemctl restart foodsite
sudo systemctl restart nginx

echo " Deployment complete"

EOF
                '''
            }
        }
    }
}
