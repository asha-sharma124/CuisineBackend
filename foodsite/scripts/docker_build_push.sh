#!/bin/bash
USERNAME=$1
IMAGE_TAG=$2

docker build -t $USERNAME/foodsite:$IMAGE_TAG foodsite
docker tag $USERNAME/foodsite:$IMAGE_TAG $USERNAME/foodsite:latest
docker push $USERNAME/foodsite:$IMAGE_TAG
docker push $USERNAME/foodsite:latest
