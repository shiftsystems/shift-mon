#!/bin/bash
cd /opt/shift-mon
docker compose pull
docker compose up -d
echo "y" | docker system prune