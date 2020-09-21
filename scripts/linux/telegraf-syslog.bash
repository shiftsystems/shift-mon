#!/bin/bash
SYSLOG_CONFIG_URL="https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/linux/50-telegraf.conf"
TELEGRAF_CONFIG_URL="https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/linux/telegraf-syslog.conf"

# install rsyslog
source /etc/os-release

case $ID in
    "debian"|"ubuntu"|"neon")
        apt install rsyslog
        ;;
    "fedora")
        dnf install rsyslog
        ;;

esac

# download syslog config
curl -o /etc/rsyslog.d/50-telegraf.conf $SYSLOG_CONFIG_URL

# download telegraf config
curl -o /etc/telegraf/telegraf.d/telegraf-syslog.conf $TELEGRAF_CONFIG_URL

# restart telegraf and syslog
systemctl restart telegraf rsyslog