## Requirements
* Ubuntu 20.04 (Probably works with 18.04)
* A Redhat 8 based distro
* A domain for obtaining Let's Encrypt certificates if you are using NGINX

## Installation

### Setup Ansible on your machine 

#### Ubuntu
 ```sudo apt update && sudo apt install ansible git python3-apt software-properties-common```

#### RedHat and RedHat Derivitaves
1. ```sudo dnf install epel-release```
2. ```sudo dnf install ansible git```

### Clone the Repo
Clone the repo by running the following command ```git clone https://gitlab.com/shiftsystems/shift-mon.git && cd shift-mon```

### Move your inventory somewhere else and fill it out
Please make sure you have DNS A and/or AAAA records for the domains you want Victoirametrics, Loki, and Grafana to respond to. 

To prevent conflicts in the future, I recommend copying the Ansible inventory outside of the git repo. I copy mine to the parent folder of the repo by running ```cp inventory ../```

Next, Fill out the inventory by running ```nano ../inventory```.
**DO NOT EDIT THE INVENTORY IN THE REPO THIS WILL CAUSE PROBELEMS LATER**
I will explain what each of the values means.
* The host section requires you have one host where software will be installed. 
Each indented line below  lists the components that make up Shift RMM. 
True means turn it on and false means turn it off. 
If you want to use separate hosts for Victoriametrics, Loki, and/or Grafana copy the host block and change all components you want installed on that box to true for each host.
* nginx: whether or not to use NGINX as a reverse proxy on all hosts.
* ansible_python_interpreter: the Python interpreter that Ansible to use please do not change as this could cause Ansible to not work correctly or ignore the inventory.
* loki:
  * url: url that telegraf should send logs to
  * domain: Fully qualified domain name (fqdn) for the loki server
  * user: username setup for loki for telegraf agents
  * password: password setup for loki for telegraf agents
* victoria:
  * url: url that telegraf should send metrics to
  * domain: Fully qualified domain name (fqdn) for the victoriametrics server
  * user: username setup for victoriametrics for telegraf agents
  * password: password setup for victoriametrics for telegraf agents
* email
  * enabled: weather or not grafana should be configured for SMTP/E-mail alerts
  * host: hostname of the mails server
  * alert_from_address: email address Grafana should be sent from
  * alert_from_name: Name Grafana should display for email alerts
  * user (optional): username for the SMTP account on your mail server
  * password (optional):  password for the SMTP account on your mail server
  * port: port that your mailserver is using

### Run the Playbook for the First Time and Updating
while in the shift-rmm directory, run the following command:
```ansible-playbook shift-rmm.yml -i ../inventory --ask-become-pass```

### Setup the Admin User for InfluxDB
First, navigate to the URL you defined for InfluxDB and click get started.
Then fill out your username and password. 
For the initial org name use shiftsystems if you don't want to change any scripts or configs later, and set the initial bucket to anything but Windows, Linux, Proxmox, or Pfsense otherwise you will not be able to import the template.
You can add additional buckets later.
In the next screen, just click on configure later since we will be configuring our own buckets and dashboards.

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