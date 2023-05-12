# Docker
The telegraf playbook will discover that docker is running on a linux box and place the config for scraping metrics from the docker socket.
The docker log plugin has issues with sending data to loki so to see docker logs in shift-mon so we are using the syslog driver in it's place.
Using syslog also matches the behavior of podman which makes querying work better in a mixed environment.
For docker to be able to forward the logs we are using the local syslog server built in to the ansible role which requires the sylosg variable be set for that host
set `syslog: rsyslog` if you want the telegraf role to configure syslog for your or set it to anything else if you are using a custom setup or syslog-ng
It is best to setup the syslog driver in docker by creating a `/etc/docker/daemon.json` and placing  the following content in it or adding it to an existing daemon.json
```json
{
  "log-driver": "syslog",
  "log-opts": {
    "syslog-address": "udp://localhost:6667",
    "syslog-format": "rfc5424",
    "tag": "{{.Name}}"
  }
}
```
After this please restart docker and recreate all your containers for this config to apply successfully.