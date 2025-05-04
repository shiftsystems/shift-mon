# ShiftMon

An open source monitoring and logging tool based on Telegraf, Victoriametrics, Loki, Grafana, and Uptime Kuma.

![matrix room](https://img.shields.io/matrix/shiftsystems:matrix.org)
![Gitlab CI](https://img.shields.io/gitlab/pipeline-status/shiftsystems/shift-rmm?branch=main)


## Installation
[Follow the intructions in the docs](docs/Install.md)

## Configuring Alerts
[Instructions for configuring alerts can be found here](docs/Alerting.md)

## How it works
* Telegraf role deploys monitoring agent to devices
  * Tries to instrument services ShiftMon supports automatically
  * Uses variables inventory for scraping remote data
* ShiftMon roles will do the following by default
  * Deploy Victoriametrics for metric storage
  * Deploy Victorialogs for log management
  * Deploy Grafana for viewing this data and alerts
  * Configure Valkey cache for Grafana
  * vmauth for routing requests and managing credentials
  * vmalert for evaluating alerting and recording rules
  * alertmanager for routing and send alerts

![Network Diagram](/docs/images/shift-mon-diagram.png)

## Contribution

### Time 
We appreciate your contribution by helping with documentation, contributing code, or submitting an issue

### Active hardware
If there is a platform you wish we supported and are willing to send us monitoring data, please reach out to mathias@shiftsystems.net

### Financial 
If you require assistance deploying ShiftMon or wish to have an issue prioritized, we offer hourly consulting.

Please Contact sales@shiftsystems.net or message @tiny:shiftsystems.net in Matrix for details.

We also take donations via Paypal and Buymeacoffee 

<a href="https://www.buymeacoffee.com/shiftsystems" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

[Paypal](https://www.paypal.com/donate?hosted_button_id=384786R5ULJRC)


## Social Media

We try to publish content twice a month either on [the Shiftsystems website](https://shiftsystems.net) or our [Youtube channel](https://www.youtube.com/channel/UCO2EZwVPok3Plop3ekonf7A).
 
## Supported Platforms and Applications
* Windows
* Linux
* PFSense
* OPNSense
* Black Box Monitoring
  * HTTPS Healthchecks
  * DNS Healthchecks
  * TCP Healthchecks
  * Ping Healthchecks
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
* MySQL (no dashboard yet)
* OpenLDAP (no dashboard yet)
* HAProxy (no dashboard yet)
* ZFS
* NTOPNG
* Syslog Data
* Internal Metrics
* Nut
* SMART

## Security Features
* LDAP for Grafana
* User defined OIDC sign on for Grafana
* Google SSO (OIDC)
* Updates every time the service is restarted

