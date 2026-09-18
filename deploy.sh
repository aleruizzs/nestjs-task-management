#!/usr/bin/env bash
set -e

REGION="eu-west-3"
ACCOUNT="974389254652"
REPO="demo-app"
REGISTRY="$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
IMAGE="$REGISTRY/$REPO:latest"

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY
docker pull $IMAGE
docker rm -f demo-app || true
docker run -d --name demo-app --restart always -p 3000:3000 --env-file /home/ubuntu/.env.stage.prod $IMAGE