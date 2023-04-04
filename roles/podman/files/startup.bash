#!/bin/bash
cd /opt/shift-mon
podman pull $(grep image: docker-compose.yml | sed -e "s/image://" -e "s/ //g" | tr '\n' ' ')
podman-compose up -d
echo "y" | podman system prune