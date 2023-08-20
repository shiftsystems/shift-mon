# Shift Mon

An open source monitoring and logging tool based on Telegraf, Victoriametrics, Loki, Grafana, and Uptime Kuma.

![matrix room](https://img.shields.io/matrix/shiftsystems:matrix.org)
![Gitlab CI](https://img.shields.io/gitlab/pipeline-status/shiftsystems/shift-rmm?branch=main)


## Installation
[Follow the intructions in the docs](docs/Install.md)

## Configuring Alerts
[Instructions for configuring alerts can be found here](docs/Alerting.md)

## How it works
* Telegraf role deploys monitoring agent to devices
  * tries to Instrument services shift-mon supports automatically
  * Uses variables inventory for scraping remote data
* shift-mon roles will do the following by default
  * Deploy Victoriametrics for metric storage
  * Deploy Loki for log and alert state storage
  * Deploy Grafana for viewing this data and send alerts
  * Configure Redis cache for Grafana
* Optionally Shift-mon can deploy the following
  * Grafana Oncall for advanced alerting features and send health checks to Grafana cloud
  * Deploy Uptimekuma for blackbox checks

![Network Diagram](/docs/images/shift-mon-diagram.png)

## Contribution

### Time 
We appreciate your contribution by helping with documentation, contributing code, or submitting an issue

### Active hardware
If there is a platform you wish we supported and are willing to send us monitoring data please reach out to mathias@shiftsystems.net

### Money 
You can purchase shift-mon as a managed or solution. 
We also do consulting for ansible, meshcentral, telegraf, and influxdb. 
Please fill out the contact form on shiftsystems.net or email sales@shiftsystems.net

[Paypal](https://www.paypal.com/donate?hosted_button_id=384786R5ULJRC)


## Social Media

We try to publish content twice a month on either on [the Shiftsystems website](https://shiftsystems.net) or our [Youtube channel](https://www.youtube.com/channel/UCO2EZwVPok3Plop3ekonf7A).
 
## Supported Platforms and Applications
* Windows
* Linux
* PFSense
* OPNSense
* Docker
* Podman
* Crowdsec
* Uptime Kuma
* Apache
* Nginx
* Caddy
* Traefik
* Vsphere
* Proxmox
* Libvirt
* ipvs (no dashboard yet)
* mysql (no dashboard yet)
* ZFS
* NTOPNG
* Syslog Data
* Internal Metrics

## Security Features
* LDAP for Grafana
* User defined OIDC sign on for Grafana
* Google SSO (OIDC)
* Updates every time the service is restarted