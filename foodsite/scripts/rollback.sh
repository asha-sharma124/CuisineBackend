#!/bin/bash

DOCKERHUB_USERNAME=$1
PREV_TAG=$2
JUMP_KEY=$3
PRIVATE_KEY=$4
JUMP_USER=$5
JUMP_HOST=$6
PRIVATE_USER=$7
PRIVATE_HOST=$8
PROJECT_DIR=$9

ssh -o StrictHostKeyChecking=no -i $JUMP_KEY $JUMP_USER@$JUMP_HOST << EOF
  ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY $PRIVATE_USER@$PRIVATE_HOST << EOC
    cd $PROJECT_DIR
    docker pull $DOCKERHUB_USERNAME/foodsite:$PREV_TAG
    docker stop foodsite || true && docker rm foodsite || true
    docker run -d --name foodsite -p 80:80 $DOCKERHUB_USERNAME/foodsite:$PREV_TAG
EOC
EOF
