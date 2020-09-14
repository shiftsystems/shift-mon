# Shift RMM

An open source remote monitoring and management tool based on Telegraf, Influxdb, and meshcentral.


## Requirements
* Ubuntu 20.04 (Probably works with 18.04)
* a domain for obtaining letsencrypt certs if you are using nginx

## Installation

### Setup Ansible on your machine 
* On Ubuntu install Ansible by running ```sudo apt update && sudo apt install ansible git python3-apt software-properties-common```

### Clone the Repo
clone the repo by running the following command ```git clone https://gitlab.com/shiftsystems/shift-rmm.git && cd shift-rmm```

### Move your inventory somewhere else and fill it out
Please make sure you have DNS A and/or AAAA records for the domains you want meshcentral, grafana, and Influxdb to respond on. 

To prevent conflicts in the future I recommend copying the ansible inventory outside of the git repo. I copy mine to the parent folder of the repo by running ```cp inventory ../```

Next Fill out the inventory. I will explain what each of the values mean.
* ansible_connection: how ansible should communicate with the host(s) use local if you are running the playbook from the host that you are running shift rmm on if you are using a remote host or multiple hosts change it from local to ssh
* influx_fqdn: the domain your want Influxdb to be on. Requires a DNS A and/or AAAA record pointed to it
* grafana_fqdn: the domain you want grafana to be on. Requires a DNS A and/or AAAA record pointed to it Grafana is not offically supported but there if you perfer it for dashboarding
* meshcentral_fqdn: the domain you want mesh to be on. Requires a DNS A and/or AAAA record pointed to it
* from_email: the email address used for letsencrypt certs
* ansible_python_interpreter: the python interpreter that ansible to use please do not change as this could cause ansible to not work correctly or ignore the inventory.
* title: header for the title page
* title2: text for the title page
* mail_host: the smtp server you wish to use
* from_address: the email address email will be sent from
* email_username: username for the email account that you wish to send email from
* email_password: password for the email account that you wish to send email from

If you want to use your logo replace the logo.png file with your own image.
You can run meshcentral and Influxdb on separate hosts. To do so just copy the host block and change the meshcentral, grafana, and influx accordingly. if nginx is set to true it will install nginx on both hosts and get the letsencrypt cert for the correct domains on the correct host. Set nginx to false if you plan on using haproxy or a different reverse proxy/load balancer. 

### Run the Playbook for the First Time and Updating
while in the shift-rmm directory run the following command
```ansible-playbook shift-rmm.yml -i ../inventory --ask-become-pass```

### Setup the Admin User for Influxdb
First navigate to the url you defined for Influxdb and click get started.
Then fill out your username and password. 
For the initial org name use shiftsystems if you don't want to change any scripts or configs later, and set the initial bucket to anything but windows, linux, proxmox, or pfsense otherwise you will not be able to import the template.
You can add additional buckets later.
In the next Screen just click on configure later since we will be configuring our own buckets and dashboards.

### Generating Tokens in Influxdb
Once you have setup your admin account click on data then click on tokens then click generate token. From the Dropdown click on the all access token, name it, then click save. Click on the blue text that has your token's name. Then click copy to clipboard and paste it in your ansible inventory in between the empty quotes for influxdb_token.

### Import the Influxdb Dashboards, and Buckets
Now that you have an access token defined run the ansible task for importing the shift rmm template by running ```ansible-playbook shift-rmm.yml -i ../inventory --ask-become-pass --tags "influx_template"```. Whenever your run this playbook to update meshcentral this will import the latest version of this influx template.
For the meshcentral integration to work correctly please change the mesh_info variable from tes.example.com to your domain by clicking on settings > variables mesh_info. This will need to be done after each update 

### Generate Additional Tokens for Each Bucket
It is not good practice to use all access tokens for telegraf collectors because if one endpoint gets compromised they will be able to have their way with your Influxdb instance.
To prevent this generate a token with write only access to the bucket it needs by going to date > tokens > generate > read write and using selecting the correct bucket under write.
Repeat this step for each bucket you plan on using. 
If a host does get compromised in this scenario then it will be able to write bad data to the bucket it has access to instead of muck about your whole database.

### Setup the admin user for Meshcentral
Go the meshcentral url you defined in your inventory,click on create account and fille in your username, password and email address. You should receive a verification email. 
Once you do please click on the link to confirm your account. 
You will now need to create a device group which you can do by clicking on the create device group button. 
There is no limit to the amount of device groups you can have.

### Add the Scripting Plugin for Meshcentral
click on the my server icon which is the bottom icon on the left. Click on the plugins tab, and click on download plugin then paste in ```https://raw.githubusercontent.com/ryanblenis/MeshCentral-ScriptTask/master/config.json```. Next on the action dropdown menu click on install.

### Adding your first agents 
Agents can either be added by downloading an agent from meshcentral by clicking on add agent in the ui and slecting the correct option from the dropdown.
Agents can also be given an invite link that can be sent via email or by link to them on a different site by clicking on agent invite.

### Upload and Tweak scripts 
you should be able to find various scripts in the scripts folder that you can upload to your meshcentral server and push out to agents on an ad hoc or scheduled basis. To upload script copy the script, click on a node were the meshagent is installed click on plugins then click on new. Name the script and give it the correct file extension. Then paste in the script and hit save. Right now there are some issues with this plugin and you might have to edit the script, paste it in and hit save multiple times. 


### Pushing Telegraf to Windows and Linux endpoints via meshcentral
WIP

### Pushing Telegraf to Linux hosts via ansible
WIP

## Installing Telegraf on Other devices

### Proxmox
Use the instructions located on the [Shfit Systems blog](https://shiftsystems.net/blog/proxmox-metrics-to-influx/)

### Pfsense
WIP