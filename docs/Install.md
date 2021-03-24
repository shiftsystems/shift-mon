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
Clone the repo by running the following command ```git clone https://gitlab.com/shiftsystems/shift-rmm.git && cd shift-rmm```

### Move your inventory somewhere else and fill it out
Please make sure you have DNS A and/or AAAA records for the domains you want MeshCentral, Grafana, and InfluxDB to respond to. 

To prevent conflicts in the future, I recommend copying the Ansible inventory outside of the git repo. I copy mine to the parent folder of the repo by running ```cp inventory ../```

Next, Fill out the inventory by running ```nano ../inventory```.
**DO NOT EDIT THE INVENTORY IN THE REPO THIS WILL CAUSE PROBELEMS LATER**
I will explain what each of the values means.
* The host section requires you have one host where software will be installed. 
Each indented line below  lists the components that make up Shift RMM. 
True means turn it on and false means turn it off. 
If you want to use separate hosts for InfluxDB and MeshCentral, copy the host block and change all components you want installed on that box to true for each host.
* influx_fqdn: the domain your want InfluxDB to be on. Requires a DNS A and/or AAAA record pointed to it
* grafana_fqdn: the domain you want Grafana to be on. Requires a DNS A and/or AAAA record pointed to it Grafana is not officially supported but there if you prefer it for dashboarding
* meshcentral_fqdn: the domain you want MeshCentral to be on. Requires a DNS A and/or AAAA record pointed to it
* nginx: whether or not to use NGINX as a reverse proxy on all hosts.
* ansible_python_interpreter: the Python interpreter that Ansible to use please do not change as this could cause Ansible to not work correctly or ignore the inventory.
* ansible_connection: how Ansible should communicate with the host(s). 
Use local if you are running the playbook from the host that Shift RMM runs on. 
If you are using a remote host or multiple hosts, change it from local to ssh
* title_text: "Title that shows on main page"
* welcome_text: "tag line that shows on the login page"
* footer_text: HTML that displays on the bottom left of every page.
* certbot_email: the email address used for Let's Encrypt certs
* mail_host: the SMTP server you wish to use
* from_address: the email address email will be sent from
* email_username: username for the email account that you wish to send email from
* email_password: password for the email account that you wish to send email from
* influx_token: leave empty for now we will add our Influx token after InfluxDB has been installed
* influx_org: leave as shiftsystems unless you want to edit a bunch of scripts later for custom branding.

If you want to use your logo, replace the logo.png file with your own image.
You can run MeshCentral and InfluxDB on separate hosts. To do so, just copy the host block and change the MeshCentral, Grafana, and Influx accordingly. If NGINX is set to true, it will install NGINX on both hosts and get the Let's Encrypt cert for the correct domains on the correct host. Set NGINX to false if you plan on using HAProxy or a different reverse proxy/load balancer.

### Run the Playbook for the First Time and Updating
while in the shift-rmm directory, run the following command:
```ansible-playbook shift-rmm.yml -i ../inventory --ask-become-pass```

### Setup the Admin User for InfluxDB
First, navigate to the URL you defined for InfluxDB and click get started.
Then fill out your username and password. 
For the initial org name use shiftsystems if you don't want to change any scripts or configs later, and set the initial bucket to anything but Windows, Linux, Proxmox, or Pfsense otherwise you will not be able to import the template.
You can add additional buckets later.
In the next screen, just click on configure later since we will be configuring our own buckets and dashboards.

### Generating Tokens in InfluxDB
Once you have set up your admin account click on data then click on tokens then click generate token. From the Dropdown click on the all-access token, name it, then click save. Click on the blue text that has your token's name. Then click copy to clipboard and paste it in your Ansible inventory in between the empty quotes for influxdb_token.

### Import the InfluxDB Dashboards and Buckets
Now that you have an access token defined, run the Ansible task for importing the Shift RMM template by running ```ansible-playbook shift-rmm.yml -i ../inventory --ask-become-pass --tags "influx_template"```. Whenever you run this playbook to update Shift-rmm, this will import the latest version of this Influx template.
For the MeshCentral integration to work correctly, **PLEASE CHANGE** the ```mesh_info``` variable from test.example.com to your domain by clicking on settings > variables mesh_info. This will need to be done after each update.

### Generate Additional Tokens for Each Bucket
It is not good practice to use all access tokens for Telegraf collectors because if one endpoint gets compromised, they will be able to have their way with your InfluxDB instance.
To prevent this, generate a token with write-only access to the bucket it needs by going to date > tokens > generate > read-write and using selecting the correct bucket under write.
Repeat this step for each bucket you plan on using. 
If a host does get compromised in this scenario, it will be able to write bad data to the bucket it has access to instead of muck about your whole database.

### Setup the Admin User for MeshCentral
Go the MeshCentral URL you defined in your inventory, click on create an account, and fill in your information (username, password, and email address). You should receive a verification email. 
Once you receive the email, click on the link to confirm your account. 
You will now need to create a device group by clicking on the create device group button. 
There is no limit to the number of device groups you can have.

### Add the Scripting Plugin for MeshCentral
Out-of-the-box MeshCentral cannot push scripts. A plugin needs to be installed. To install the plugin, click on the "my server" icon which is the bottom icon on the left. Click on the Plugins tab, and click on download plugin then paste in ```https://raw.githubusercontent.com/ryanblenis/MeshCentral-ScriptTask/master/config.json```. Next, on the action dropdown menu click on install.

### Adding Your First Agents 
Agents can either be added by downloading an agent from MeshCentral by clicking on add agent in the UI and selecting the correct option from the dropdown.
Agents can also be given an invite link that can be sent via email or by linking to them on a different site by clicking on agent invite.

### Upload and Tweak Scripts 
You should be able to find various scripts in the Scripts folder that you can upload to your MeshCentral server and push out to agents on an ad hoc or scheduled basis. To upload a script, copy the script and click on a node where the MeshAgent is installed click on plugins then click on new. Name the script and give it the correct file extension. Then paste in the script and hit save. Right now there are some issues with this plugin. You might have to edit the script and paste it in and hit save multiple times. 


### Pushing Telegraf to Windows and Linux Endpoints via MeshCentral
WIP

### Pushing Telegraf to Linux hosts via Ansible
WIP

## Installing Telegraf on Other Devices

### Proxmox
Use the instructions located on the [Shift Systems blog](https://shiftsystems.net/blog/proxmox-metrics-to-influx/)

### Pfsense
First, login to your Pfsense firewall as an administrative user.
Next, click on system > package manager then click on available packages.
Type Telegraf in the search box, then click on the install button next to were it says Telegraf.
Click on the confirm and wait for the package to install.
After Telegraf is installed, click on services > Telegraf
Tick the box were it says enable Telegraf and paste in the contents of telegraf_ips.conf. If you are using Snort and have blocking turned use the telegraf_ips.conf. If you are using it for just intrustion detection or not using Snort at all, use telegraf_ids.conf.
Change influxdb.example.com to your InfluxDB domain, replace GET_A_TOKEN_FROM_YOUR_INFLUXDB_INSTANCE with write access to the Pfsense bucket, and click save.
If you are not sure how to get a token, please refer to the Generate Additional Tokens for Each Bucket section of this document
