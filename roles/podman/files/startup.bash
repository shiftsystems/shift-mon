#!/bin/bash
cd /opt/shift-mon
podman pull docker.io/grafana/grafana-oss:latest docker.io/grafana/loki:latest docker.io/victoriametrics/victoria-metrics:stable docker.io/louislam/uptime-kuma:1  docker.io/crowdsecurity/crowdsec:latest docker.io/fbonalair/traefik-crowdsec-bouncer:latest
podman-compose up -d
echo "y" | podman system prune