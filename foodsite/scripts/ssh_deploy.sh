#!/bin/bash

JUMP_KEY=$1
EC2_KEY=$2
JUMP_USER=$3
JUMP_HOST=$4
PRIVATE_USER=$5
PRIVATE_HOST=$6
PRIVATE_PROJECT_DIR=$7
DOCKER_USER=$8
DOCKER_PASS=$9
IMAGE_TAG=${10}


echo "Sending code to Jump Server..."
rsync -avz --exclude='.env' \
  -e "ssh -o ProxyCommand='ssh -i $JUMP_KEY -o StrictHostKeyChecking=no $JUMP_USER@$JUMP_HOST -W %h:%p' \
  -i $EC2_KEY -o StrictHostKeyChecking=no" \
  ./foodsite/ $PRIVATE_USER@$PRIVATE_HOST:$PRIVATE_PROJECT_DIR/

echo "Deploying to Private EC2..."
ssh -o ProxyCommand="ssh -i $JUMP_KEY -o StrictHostKeyChecking=no $JUMP_USER@$JUMP_HOST -W %h:%p" \
    -i $EC2_KEY -o StrictHostKeyChecking=no \
    $PRIVATE_USER@$PRIVATE_HOST \
    "cd $PRIVATE_PROJECT_DIR && chmod +x ./scripts/deploy.sh && ./scripts/deploy.sh $DOCKER_USER $DOCKER_PASS $PRIVATE_PROJECT_DIR $IMAGE_TAG"
