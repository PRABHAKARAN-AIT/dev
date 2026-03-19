#!/bin/bash
set -e
echo 'Starting Development Deployment...'
cd /home/ec2-user/projects/dev || exit
git fetch origin
git reset --hard origin/development
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml build --no-cache
docker-compose -f docker-compose.dev.yml up -d
echo 'Development Deployment Complete'