#!/bin/bash
cd /opt/shift-mon
podman-compose pull
podman-compose up -d
echo "y" | podman system prune