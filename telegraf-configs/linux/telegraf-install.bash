#!/bin/bash

# environment settings
TELEGRAF_CONFIG_URL="https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/linux/telegraf.conf"
INFLUXDB_URL="https://test.example.com"
TELEGRAF_BUCKET="linux"
TELEGRAF_ORG="shiftsystems"
TELEGRAF_TOKEN="GET_YOUR_OWN_TOKEN"
source /etc/os-release

case $ID in
    "debian")
        apt update
        apt install apt-transport-https
        wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
        test $VERSION_ID = "7" && echo "deb https://repos.influxdata.com/debian wheezy stable" | tee /etc/apt/sources.list.d/influxdb.list
        test $VERSION_ID = "8" && echo "deb https://repos.influxdata.com/debian jessie stable" | tee /etc/apt/sources.list.d/influxdb.list
        test $VERSION_ID = "9" && echo "deb https://repos.influxdata.com/debian stretch stable" | tee /etc/apt/sources.list.d/influxdb.list
        test $VERSION_ID = "10" && echo "deb https://repos.influxdata.com/debian buster stable" | tee /etc/apt/sources.list.d/influxdb.list
        apt update
        apt -y install telegraf
        ;;
    "ubuntu")
        source /etc/lsb-release
        wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
        echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list
        apt update
        apt -y dist-upgrade
        ;;
    "fedora")
        cat <<EOF | tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository
baseurl = https://repos.influxdata.com/centos/8/x86_64/stable/
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

        yum -y install telegraf
        ;;
esac


# setup environment variables
cat <<EOF | tee /etc/default/telegraf
bucket="$TELEGRAF_BUCKET"
org="$TELEGRAF_ORG"
token="$TELEGRAF_TOKEN"
url="$INFLUXDB_URL"
EOF
# copy telegraf config from gitlab
curl -o /etc/telegraf/telegraf.conf $TELEGRAF_CONFIG_URL
# restart and enable telegraf
systemctl enable telegraf
systemctl restart telegraf