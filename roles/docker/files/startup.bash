#!/bin/bash
cd /opt/shift-mon
docker pull $(grep image: docker-compose.yml | sed -e "s/image://" -e "s/ //g" | tr '\n' ' ')
docker compose up -d
echo "y" | docker system prune