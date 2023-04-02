#!/bin/bash
cd /opt/shift-mon
docker pull docker.io/grafana/grafana-oss:latest docker.io/grafana/loki:latest docker.io/victoriametrics/victoria-metrics:stable docker.io/louislam/uptime-kuma:1  docker.io/crowdsecurity/crowdsec:latest docker.io/fbonalair/traefik-crowdsec-bouncer:latest
docker-compose up -d
echo "y" | docker system prune