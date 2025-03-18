# TODO
* update diagram

## What is different

### Breaking
* no more Grafana oncall (it's being killed)
* no more uptime kuma (we have telegraf)
* Loki is only a key value store for alert state

### Planned Changes
* alertmanager is added
* focused on using vmalert and manager instead of Grafana managed alerts
  * easier to manage as code
  * easier to keep alertstate
  * things you should do in the UI are available in the UI
* Victorialogs is the logging backend
* my alerts are available for alert groups (off by default)
* All containers besides traefik will run as the shiftmon user
* dashboards use Victorialogs and Victoriametrics data source
* structured logs get parsed into other fields
