# TODO
* add SMTP to default alerting template
* fix default alerting groups
* run everything as the shiftmon user
* separate non resolving alerts
* update diagram
* fix all the dashboards
* don't check for certs on http prefixed urls

## What is different

### Breaking
* no more Grafana oncall
* no more uptime kuma
* Loki is only a key value store for alert state

### Planned Changes
* alertmanager is added
* focused on using vmalert and manager instead of Grafana managed alerts
  * easier to manage as code
* Victorialogs is the default logging backend
* my alerts are available for alert groups (off by default)
* All containers besides traefik will run as the shiftmon user
* dashboards use Victorialogs and Victoriametrics data source
* structured logs get parsed into other fields
