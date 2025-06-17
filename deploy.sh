#!/bin/bash
echo "docker login "
docker login -u "$1" -p "$2"

echo "navigate to directory "
cd "$3"

echo " Updating image tag in docker-compose.yml..."
sed -i "s|image: .*/foodsite:.*|image: $1/foodsite:$4|g" docker-compose.yml

echo "Pulling, Stopping, and Starting containers..."
sudo docker compose pull
sudo docker compose down
sudo docker compose up -d


