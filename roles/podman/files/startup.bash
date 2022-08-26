#!/bin/bash
cd /opt/shift-mon
podman images | grep -v REPOSITORY | awk '{print $1}' | uniq -u | xargs -L1 podman pull
podman-compose up -d