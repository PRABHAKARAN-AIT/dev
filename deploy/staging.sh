#!/bin/bash
set -e
echo 'Starting Staging Deployment...'
cd /home/ec2-user/projects/dev || exit
git fetch origin
git reset --hard origin/release-candidate
docker-compose -f docker-compose.yml down
docker-compose -f docker-compose.yml build --no-cache
docker-compose -f docker-compose.yml up -d
echo 'Staging Deployment Complete'