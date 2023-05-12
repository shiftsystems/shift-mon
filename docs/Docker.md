# Docker
The telegraf playbook will discover that docker is running on a linux box and place the config for scraping metrics from the docker socket.
The docker log plugin has issues with sending data to loki so to see docker logs in shift-mon.
It is best to setup the syslog driver in docker by creating a `/etc/docker/daemon.json` and placing  the following content in it or adding it to an existing daemon.json
```json
{
  "log-driver": "syslog",
  "log-opts": {
    "syslog-format": "rfc5424",
    "tag": "{{.Name}}"
  }
}
```
After this please restart docker and recreate all your containers for this config to apply successfully.