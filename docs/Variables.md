### This section is for ldap and only needs populated if you wish to use ldap
* ldap_host: hostname of the ldap server to this is optional
* ldap_port: port to use for ldap communication usually 389 for plaintext(please don't use plain text ldap) or starttls or 636 for ssl/tls
* bind_dn: bind user string for ldap auth
* base_dn: base domain ldap string
* bind_password: password for the ldap_bind account
* admin_group: ldap string for users who should be grafana admins
* editor_group: ldap string for users who should be grafana admins
* viewer_group: ldap string for users who should be grafana admins


### syslog
* syslog: weather or not to configure telegraf to listen for syslog RFC5424 messages on udp port 6666
  * set to rsyslog if you want rsyslog installed configured to forward to telegraf 
  * set it to anything besides rsyslog if you plan to configure log forwarding to udp://localhost:6666 yourself.
  * comment out if you don't want syslog messages forwarded.

* remote_syslog weather or not to listen to remote syslog RFC5424 on udp port 6666 for things like forwarding syslog from a firewall.

### Specific info for each of the services 
* loki:
  * url: url that telegraf should send logs to
  * domain: Fully qualified domain name (fqdn) for the loki server
  * retention_period: how long to store data before deletion use d for day and y for years
  * cert_path:  absolute path to SSL certificate for loki should be pem encoded this is optional
  * key_path:  absolute path to SSL key for loki should be pem encoded this is optional
  * tsdb_date: Date formated YYYY-MM-DD that states when to store logs in TSDB format instead of boltdb format this optional but should be set
* victoria:
  * url: url that telegraf should send metrics to
  * domain: Fully qualified domain name (fqdn) for the victoriametrics server
  * retention_period: how long to store data before deletion use d for day and y for years
  * cert_path:  absolute path to SSL certificate for victoriametrics should be pem encoded this is optional
  * key_path:  absolute path to SSL key for victoriametrics should be pem encoded this is optional
  * insecure: weather or not to expose plain http metrics for victoriametrics outside of the container this is for things like proxmox that can be picky about basic auth and SSL please avoid using if possible
* grafana
  * domain: Fully qualified domain name of the grafana server
  * cert_path:  absolute path to SSL certificate for loki should be pem encoded this is optional
  * key_path:  absolute path to SSL key for loki should be pem encoded this is optional
* uptimekuma
  * domain: Fully qualified domain of the uptime kuma server
  * cert_path:  absolute path to SSL certificate for loki should be pem encoded this is optional
  * key_path:  absolute path to SSL key for loki should be pem encoded this is optional

### Email this is optional
* email
  * enabled: weather or not grafana should be configured for SMTP/E-mail alerts
  * host: hostname of the mails server
  * alert_from_address: email address Grafana should be sent from
  * alert_from_name: Name Grafana should display for email alerts
  * user (optional): username for the SMTP account on your mail server
  * password (optional):  password for the SMTP account on your mail server
  * port: port that your mailserver is using

### User dictionary this is required
* users is a dictonary of users and passwords for http basic auth for loki and victoriametrics that also gets pushed out to telegraf

### This section is for SSL/TLS and the only required value is an email address all other values are for certs that don't use letsencrypt with HTTP verification
* tls.email: email address to use for sending letsencrypt certificates
* providers the list of DNS providers that traefik can use to obtain certs via DNS verification, this is optional. By default traefik will attempt to use http verification. See the [Traefik Docs](https://doc.traefik.io/traefik/https/acme/#providers) for provider specific information
* acme_url is a custom acme url to use if you want to use your own acme provider like zero SSL. The acme url must have a valid ssl certificate otherwise it will not obtain a cert