# Variables 
This section of the docs shows all possible variables  in shiftmon and is broken out by Role

## Victoriametrics

victoria:
  license: license file that unlocks enterprise features of Victoriametrics and allows for deploying vmanomaly
  domain: Fully Qualified Domain Name to use for Victoriametrics.
  url: URL Telegraf will use for sending data to Victoriametrics
  retention_period: how long Victoriametrics should retain samples for deletion
  downsampling_period: downsampling policy to apply to metrics requires defining `victoria.license`
  retention_filter: retention filter to be applied to data stored in Victoriametrics this requires `victoria.license` to be defined
  tokens: a list of tokens that have Read write access to the Victoriametrics in addition to the `victorialogs_token` variable
  cert_path:  absolute path to SSL certificate for Victoriametrics should be pem encoded this is optional. By default, shiftmon tries to get certs via letsencrypt
  key_path:  absolute path to SSL key for Victoriametrics should be pem encoded this is optional. By default, shiftmon tries to get certs via letsencrypt
  slow_query_threshold: Duration when queries should be logged for troubleshooting and if a license is defined it will log stats for all queries longer than this threshold. Slow queries will be logged if they take longer than 5s if not defined and query stats will not be gathered unless this is defined
## Victorialogs
  domain: Fully Qualified Domain Name to use for accessing Victorialogs
  url: URL Telegraf uses for sending logs
  retention_period: How long Victorialogs should retain logs for.
  tokens: a list of tokens that have Read write access to the Victorialogs in addition to the `victorialogs_token` variable
  cert_path:  absolute path to SSL certificate for Victorialogs should be pem encoded this is optional. By default, shiftmon tries to get certs via letsencrypt
  key_path:  absolute path to SSL key for Victorialogs should be pem encoded this is optional. By default, shiftmon tries to get certs via letsencrypt

### Alerting rules
These will all default to false to avoid alert fatigue
shiftmon_alerts_deadman_enabled: enables alerts that fire if telemetry is not sending from a given resource
shiftmon_alerts_infra_enabled: enables alerts for high resource utilization on Windows and Linux mcahines
shiftmon_alerts_blackbox_enabled: enables alerts for failing blackbox monitoring checks
shiftmon_alerts_proxmox_enabled: enables alerts for issues with proxmox like storage pools failing to mount
shiftmon_alerts_freeipa_enabled: enables alerts for issues with FreeIPA like replication failure
shiftmon_alerts_victorialogs_enabled: enables alerts for issues with Victorialogs
shiftmon_alerts_vmauth_enabled: enables alerts for issues with vmauth
shiftmon_alerts_alertmanager_enabled: enables alerts for issues with alertmanager
shiftmon_alerts_victoriametrics_enabled: enables alerts for issues with Victoriametrics
shiftmon_alerts_adguardhome_enabled: enables recording rules for 
shiftmon_alerts_log_rules: enables recording rules for tracking the number of logs per path and appname. These rules can increase the IO in the system since they frequently query a majority of the logs on the system.

telegraf_victoriametrics_config: true

### Alertmanager
shiftmon_alertmanager_config: configuration used for configuring 
alertmanager_from_email: Email address to use for
alertmanger_smtp_auth_identity: "{{ alertmanager_smtp_username }}"
smtp_host: SMTP server used by alertmanager formatted `{{ servername}}:{{ port }}` 
smtp_username: username used to authenticate to the smtp server used by alertmanager
smtp_password: password used for authenticating to the smtp server used by alertmanager
smtp_auth_identity: Who the emails appear to be sent from when sent from alertmanager. this defaults to the SMTP username
smtp_require_tls: weather or not to validate the certificate of the SMTP server
alertmanager:
  domain: optional domain to use if you want to expose alertmanager this should not be needed in most cases since most of alertmanager's features are exposed via the Grafana datasource that is configured by default.
  cert_path:  absolute path to SSL certificate for Victorialogs should be pem encoded this is optional. By default, shiftmon tries to get certs via letsencrypt
  key_path:  absolute path to SSL key for Victorialogs should be pem encoded this is optional. By default, shiftmon tries to get certs via letsencrypt


### vmanomaly
These features require a valid Victoriametrics license defined in `victoria.license`
vmanomaly_enabled: false
vmanomaly_config_path: path to vmanomaly config file

### Tokens and Users

victorialogs_token: token that has read write access to the Victorialogs API. By default this will be the only token that has access. If you need multiple tokens additional tokens can be defined in `victoria.tokens`

victoriametrics_token: token that has read write access to the Victoriametrics API. By default this will be the only token that has access. If you need multiple tokens additional tokens can be defined in `victorialogs.tokens`

victoriametrics_users: List of users that have read write access to the Victoriametrics API and UI in the format
```yaml
victoriametrics_users:
  - username: victoriametrics
    password: victoriametrics
```
victorialogs_users:
List of users that have read write access to the Victorialogs API and UI by default in the format
```yaml
victoriametrics_users:
  - username: victoriametrics
    password: victoriametrics
```

alertmanager_users: List of users that have read write access to the alertmanager API and UI in the format
```yaml
victoriametrics_users:
  - username: victoriametrics
    password: victoriametrics
```

## Grafana
* domain: Fully qualified domain name of the grafana server
* cert_path:  absolute path to SSL certificate for Grafana should be pem encoded this is optional
* key_path:  absolute path to SSL key for Grafana should be pem encoded this is optional

### Email this is optional
* email
  * enabled: weather or not grafana should be configured for SMTP/E-mail alerts
  * host: hostname of the mails server
  * alert_from_address: email address Grafana should be sent from
  * alert_from_name: Name Grafana should display for email alerts
  * user (optional): username for the SMTP account on your mail server
  * password (optional):  password for the SMTP account on your mail server
  * port: port that your mailserver is using

### These variables will enable LDAP authentication for Grafana
* ldap_host: hostname of the ldap server to this is optional
* ldap_port: port to use for ldap communication usually 389 for plaintext(please don't use plain text LDAP) or starttls or 636 for SSL/TLS
* bind_dn: bind user string for LDAP authentication
* base_dn: base domain LDAP string
* bind_password: password for the ldap_bind account
* admin_group: LDAP string for users who should be Grafana admins
* editor_group: LDAP string for users who should be Grafana admins
* viewer_group: LDAP string for users who should be Grafana admins

### Generic Oauth/OIDC
oauth:
  enabled: Boolean that determines weather or not to enable OIDC
  name: Name provider will appear as in the Grafana config and on the Login page
  client_id: Client ID from your OIDC/Oauth provider
  client_secret: Client secret from your OIDC/Oauth provider
  auth_url: API URL from your OIDC/Oauth provider
  token_url: Token URL from your OIDC/Oauth provider
  api_url: API URL from your OIDC/Oauth provider
  allowed_domains: Space separated list of domains allowed to authenticate to Grafana ex "shiftsystems.net mathiasp.me" would allow mathias@shiftsystems.net but not mathias@example.com to access Grafana
  scope: OIDC scopes that should be passed to Grafana"openid email profile"
  auto_login: Boolean that describes weather or not Users should try to login to Grafana automatically
  role_attribute_path: contains(groups, 'server-admins') && 'Admin' || contains(groups, 'Grafana Editors') && 'Editor' || 'Viewer'

### Google OAuth

google
  client_id: Google ID from the google application
  client_secret: Client secret from the google application
  allowed_domains: Space separated list of domains allowed to authenticate to Grafana ex "shiftsystems.net mathiasp.me" would allow mathias@shiftsystems.net but not mathias@example.com to access Grafana
oauth:
  auto_login: weather or not Grafana should try to automatically login users

## Telegraf
* victoriametrics_url: The URL Telegraf will send metrics too
* victoriametrics_token: The token Telegraf will use to Authenticate to Victoriametrics via vmauth
* victorialogs_url: The URL Telegraf will send logs too
* victorialogs_token: The token Telegraf will use to Authenticate to Victorialogs via vmauth
* syslog: weather or not to configure telegraf to listen for syslog RFC5424 messages on UDP port 6666
  * set to rsyslog if you want rsyslog installed configured to forward to telegraf 
  * set it to anything besides rsyslog if you plan to configure log forwarding to `udp://localhost:6666` yourself.
  * comment out if you don't want syslog messages forwarded.
* remote_syslog weather or not to listen to remote syslog RFC5424 on UDP port 6666 for things like forwarding syslog from a firewall.

## Loki
* retention_period: how long to store data before deletion use d for day and y for years
* tsdb_date: Date formated YYYY-MM-DD that states when to store logs in TSDB format instead of boltdb format this optional but should be set

## Victoriametrics:
* url: url that telegraf should send metrics to
* domain: Fully qualified domain name (fqdn) for the victoriametrics server
* retention_period: how long to store data before deletion use d for day and y for years
* cert_path:  absolute path to SSL certificate for victoriametrics should be pem encoded this is optional
* key_path:  absolute path to SSL key for victoriametrics should be pem encoded this is optional
* insecure: weather or not to expose plain http metrics for victoriametrics outside of the container this is for things like proxmox that can be picky about basic auth and SSL please avoid using if possible


### This section is for SSL/TLS and the only required value is an email address all other values are for certs that don't use letsencrypt with HTTP verification
* tls.email: email address to use for sending letsencrypt certificates
* providers the list of DNS providers that traefik can use to obtain certs via DNS verification, this is optional. By default traefik will attempt to use http verification. See the [Traefik Docs](https://doc.traefik.io/traefik/https/acme/#providers) for provider specific information
* acme_url is a custom acme url to use if you want to use your own acme provider like zero SSL. The acme url must have a valid ssl certificate otherwise it will not obtain a cert

 
