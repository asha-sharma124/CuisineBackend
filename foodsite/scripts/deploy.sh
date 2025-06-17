#!/bin/bash
set -e

echo "🔐 Docker Login"
docker login -u "$1" -p "$2"

echo "📁 Changing Directory"
cd "$3"

echo "🔄 Updating docker-compose"
sed -i "s|image: .*/foodsite:.*|image: $1/foodsite:$4|g" docker-compose.yml

echo "🚀 Restarting Containers"
sudo docker compose pull
sudo docker compose down
sudo docker compose up -d

echo "✅ Deployment Complete"
