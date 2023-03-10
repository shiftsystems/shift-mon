## Requirements
* Ubuntu 22.04
* A Redhat 8 or 9 based distro (Alma, Rocky)
* The Current version of Fedora
* 4 subdomains to point at the at the server
* As of Debian 11 there is not a good way of install podman >4.0

## Installation

### Setup Ansible on your machine 

### Ubuntu
1. ```sudo add-apt-repository ppa:ansible/ansible sudo apt update && sudo apt install ansible git python3-apt software-properties-common```
2. ```ansible-galaxy collection install community.general ansible.posix```


### RedHat and RedHat Derivitaves
1. ```sudo dnf install epel-release```
2. ```sudo dnf install ansible git ansible-collection-community-general ansible-collection-ansible-posix```

### Prepping Ubuntu Targets
You will need to run the following commands on a debian machine before running ansible. Since python3, python3-apt, and gpg are not included in some minimal installs
```sudo apt install python3 python3-apt gpg```
### Clone the Repo
Clone the repo by running the following command ```git clone https://gitlab.com/shiftsystems/shift-rmm.git && cd shift-rmm```

### Move your inventory somewhere else and fill it out
Please make sure you have DNS A and/or AAAA records for the domains you want Victoriametrics, Loki, Uptime Kuma, and Grafana to respond to. 

To prevent conflicts in the future, I recommend copying the Ansible inventory outside of the git repo. I copy mine to the parent folder of the repo by running ```cp inventory ../```

Next, Fill out the inventory by running ```nano ../inventory```.
**DO NOT EDIT THE INVENTORY IN THE REPO THIS WILL CAUSE PROBELEMS LATER**
I will explain what each of the values means.
* The hosts section requires you have one host where software will be installed. 

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

### Crowdsec api_key
* crowdsec_api_key crowdsec api for use with the crowdsec traefik bouncer. This can be obtained after installing shift-mon, execing into the containe and generating the apikey. 

### Specific info for each of the services 
* loki:
  * url: url that telegraf should send logs to
  * domain: Fully qualified domain name (fqdn) for the loki server
  * retention_period: how long to store data before deletion use d for day and y for years
  * cert_path:  absolute path to SSL certificate for loki should be pem encoded this is optional
  * key_path:  absolute path to SSL key for loki should be pem encoded this is optional
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

### TLS this is section is for SSL/TLS and the only rquired value is TLS email all other values are for certs that don't use letsencrypt with HTTP verification
* tls.email: email address to use for sending letsencrypt certificates
* providers is the list of DNS providers that traefik can use to obtain certs via DNS verification and it is optional by default traefik will attempt to use http verification. See the [Traefik Docs](https://doc.traefik.io/traefik/https/acme/#providers) for what to list for auth values and the provider
* acme_url is a custom acme url to use if you want to use your own acme provider like zero SSL. The acme url must have a valid ssl certificate otherwise it will not obtain a cert

### Run the Playbook for the First Time and Updating
while in the shift-rmm directory, run the following command:
```ansible-playbook shift-rmm.yml -i ../inventory --ask-become-pass```
to update

### Setup the Admin User for Grafana
First, navigate to the URL you defined for Grafana and click get started.
Then fill out your username and password. You should do this even if you have ldap enabled to avoid someone creating the admin account on your behalf.


### Upload and Tweak Scripts 
You should be able to find various scripts in the Scripts folder that you can upload to your MeshCentral server and push out to agents on an ad hoc or scheduled basis. To upload a script, copy the script and click on a node where the MeshAgent is installed click on plugins then click on new. Name the script and give it the correct file extension. Then paste in the script and hit save. Right now there are some issues with this plugin. You might have to edit the script and paste it in and hit save multiple times. 


### [Pushing Telegraf to Windows and Linux Endpoints via MeshCentral](docs/Telegraf/Windows.md)
This should a be a similar workflow to most RMMs. upload the scripts, change your particulars, and yeet it on to your endpoints


### [Pushing Telegraf to Linux hosts via Ansible or shell script](docs/Telegraf/Linux.md)


## Installing Telegraf on Other Devices

### Proxmox
Use the instructions located on the [Shift Systems blog](https://shiftsystems.net/blog/proxmox-metrics-to-influx/)

### [Pfsense](docs/Telegraf/PFSense.md)
First, login to your Pfsense firewall as an administrative user.
Next, click on system > package manager then click on available packages.
Type Telegraf in the search box, then click on the install button next to were it says Telegraf.
Click on the confirm and wait for the package to install.
After Telegraf is installed, click on services > Telegraf
Tick the box were it says enable Telegraf and paste in the contents of telegraf_ips.conf. If you are using Snort and have blocking turned use the telegraf_ips.conf. If you are using it for just intrustion detection or not using Snort at all, use telegraf_ids.conf.
Change influxdb.example.com to your InfluxDB domain, replace GET_A_TOKEN_FROM_YOUR_INFLUXDB_INSTANCE with write access to the Pfsense bucket, and click save.
If you are not sure how to get a token, please refer to the Generate Additional Tokens for Each Bucket section of this document


### [OPNSense](docs/Telegraf/OPNSense.md)
