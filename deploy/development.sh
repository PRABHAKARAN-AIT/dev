#!/bin/bash
set -e
echo 'Starting Development Deployment...'
cd /home/ec2-user/projects/dev || exit
echo 'Pulling latest code...'
git fetch origin
git reset --hard origin/development
echo 'Stopping old containers...'
docker stop dev-site 2>/dev/null || true
docker rm dev-site 2>/dev/null || true
echo 'Building and starting containers...'
docker build -t dev-site .
docker run -d --name dev-site -p 8081:80 dev-site
echo 'Development Deployment Complete'