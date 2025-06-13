pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Write SSH Key') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'KEY_FILE')]) {
                    sh '''
                    cp $KEY_FILE ec2_key.pem
                    chmod 600 ec2_key.pem
                    '''
                }
            }
        }

        stage('Sync Project to EC2') {
            steps {
                withCredentials([
                    string(credentialsId: 'ec2-host', variable: 'EC2_HOST'),
                    string(credentialsId: 'ec2-user', variable: 'EC2_USER'),
                    string(credentialsId: 'ec2-ssh-port', variable: 'EC2_SSH_PORT'),
                    string(credentialsId: 'ec2-project-dir', variable: 'EC2_PROJECT_DIR')
                ]) {
                    sh '''
                    rsync -avz --exclude='.env' -e "ssh -i ec2_key.pem -p $EC2_SSH_PORT -o StrictHostKeyChecking=no" \
                      ./foodsite/ $EC2_USER@$EC2_HOST:$EC2_PROJECT_DIR/
                    '''
                }
            }
        }

        stage('SSH into EC2 and Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'ec2-host', variable: 'EC2_HOST'),
                    string(credentialsId: 'ec2-user', variable: 'EC2_USER'),
                    string(credentialsId: 'ec2-ssh-port', variable: 'EC2_SSH_PORT'),
                    string(credentialsId: 'ec2-project-dir', variable: 'EC2_PROJECT_DIR')
                ]) {
                    sh '''
                    ssh -i ec2_key.pem -p $EC2_SSH_PORT -o StrictHostKeyChecking=no \
                      $EC2_USER@$EC2_HOST << 'EOF'

                      set -e

                      cd $EC2_PROJECT_DIR

                      echo "Removing old venv..."
                      rm -rf venv

                      echo "Creating new venv..."
                      python3.12 -m venv venv

                      echo "Activating and installing requirements..."
                      source venv/bin/activate
                      ls -l requirements.txt
                      venv/bin/pip install -r requirements.txt

                      echo "Applying migrations..."
                      venv/bin/python manage.py migrate

                      echo "Exporting settings..."
                      export DJANGO_SETTINGS_MODULE=foodsite.settings

                      echo "Restarting services..."
                      sudo systemctl daemon-reload
                      sudo systemctl restart foodsite
                      sudo systemctl restart nginx

                      echo "✅ Deployment complete"
                    EOF
                    '''
                }
            }
        }
    }
}
