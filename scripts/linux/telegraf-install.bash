#!/bin/bash

# environment settings
VICTORIA_URL="https://metrics.example.com"
LOKI_URL="https://logs.example.com"
VICTORIA_USER="test"
VICTORIA_PASS="test"
LOKI_USER="test"
LOKI_PASS="test"
source /etc/os-release

case $ID in
    "debian")
        apt update
        apt -y install apt-transport-https curl software-properties-common
        wget -qO- https://https://repos.influxdata.com/influxdata-archive_compat.key | apt-key add -
        test $VERSION_ID = "7" && echo "deb https://repos.influxdata.com/debian wheezy stable" | tee /etc/apt/sources.list.d/influxdb.list
        test $VERSION_ID = "8" && echo "deb https://repos.influxdata.com/debian jessie stable" | tee /etc/apt/sources.list.d/influxdb.list
        test $VERSION_ID = "9" && echo "deb https://repos.influxdata.com/debian stretch stable" | tee /etc/apt/sources.list.d/influxdb.list
        test $VERSION_ID = "10" && echo "deb https://repos.influxdata.com/debian buster stable" | tee /etc/apt/sources.list.d/influxdb.list
        apt update
        apt -y install telegraf
        ;;
    "ubuntu"|"neon")
        apt update
        apt -y install software-properties-common apt-transport-https curl
        source /etc/lsb-release
        wget -qO- https://https://repos.influxdata.com/influxdata-archive_compat.key | apt-key add -
        echo "deb https://repos.influxdata.com/ubuntu ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list
        apt -y install telegraf
        ;;
    "fedora"|"centos"|"rhel")
        cat <<EOF | tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository
baseurl = https://repos.influxdata.com/centos/8/x86_64/stable/
enabled = 1
gpgcheck = 1
gpgkey = https://https://repos.influxdata.com/influxdata-archive_compat.key
EOF

        yum -y install telegraf
        ;;
esac


# setup environment variables
cat <<EOF | tee /etc/default/telegraf
loki_url="$LOKI_URL"
loki_user="$LOKI_USER"
loki_password="$LOKI_PASS"
victoria_url="$VICTORIA_URL"
victoria_user="$VICTORIA_USER"
victoria_password="$VICTORIA_PASS"
metric_buffer_limit=100000
metric_batch_size=1000
interval="10s"
flush_interval="10s"
EOF
# copy telegraf config from gitlab
curl -o /etc/telegraf/telegraf.conf $TELEGRAF_CONFIG_URL

# restart and enable telegraf
systemctl enable telegraf
systemctl restart telegraf
