# shift-rmm

An open source remote monitoring and management tool based on Telegraf, influxdb, grafana, and meshcentral.


## Requirements
* Ubuntu 20.04 (Probably works with 18.04)
* a domain for obtaining letsencrypt certs if you are using nginx

## Installation

### Setup install ansible on your machine 
* On Ubuntu install Ansible by running ```sudo apt install ansible git python3-apt software-properties-common```
* On Fedora install Ansible by running ```sudo dnf install ansible git```

### Setup clone the repo
clone the repo by running the following command ```git clone https://gitlab.com/shiftsystems/shift-rmm.git && cd shift-rmm```

### Move your inventory somewhere else and fill it out
Please make sure you have DNS A and/or AAAA records for the domains you want meshcentral, grafana, and influxdb to respond on. 

To prevent conflicts in the future I recommend copying the ansible inventory outside of the git repo. I copy mine to the parent folder of the repo by running ```cp inventory ../```

Next Fill out the inventory. I will explain what each of the values mean.
* ansible_connection: how ansible should communicate with the host(s) use local if you are running the playbook from the host that you are running everything on if you are using a remote host or multiple hosts change it from local to ssh
* influx_fqdn: the domain your want influxdb to be on. Requires a DNS A and/or AAAA record pointed to it
* grafana_fqdn: the domain you want grafana to be on. Requires a DNS A and/or AAAA record pointed to it
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

### Run the playbook for the first time
while in the shift-rmm directory run the following command
```ansible-playbook shift-rmm.yml -i ../inventory --ask-become-pass```

### Setup the admin user for Influxdb
First navigate to the url you defined for influxdb and click get started.
Then fill out your username and password. 
For the initial org name use shiftsystems if you don't want to change any scripts or configs later, and set the initial bucket to one of the following windows or linux. You can add additional buckets later.
In the next Screen just click on configure later since we will be configuring our own buckets.

### Generating Tokens in Influxdb
Once you have setup your admin account click on data then click on tokens then click generate token. From the Dropdown click on the all access token, name it, then click save. Click on the blue text that has your token's name. Then click copy to clipboard and paste it in your ansible inventory in between the empty quotes for influxdb_token.

### Run import the influxdb dashboards, and buckets
Now that you have a access token for your database run the following command to import the influxdb dashboards by logging into your influxdb server and running the following command ```influx apply -o your org name -u https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/influx-template.yml -t THE_TOKEN_YOU_JUST_GENERATED```

### Setup the admin user for Meshcentral
Go the meshcentral url you defined in your inventory,click on create account and fille in your username, password and email address. You should receive a verification email. Once you do please click on the link to confirm your account. You will now need to create a device group which you can do by clicking on the create device group button. There is no limit to the amount of device groups you can have.

### add the scripting plugin for meshcentral
click on the my server icon which is the bottom icon on the left. Click on the plugins tab, and click on download plugin then paste in ```https://raw.githubusercontent.com/ryanblenis/MeshCentral-ScriptTask/master/config.json```. Next on the action dropdown menu click on install.

### Upload and Tweak scripts 
you should be able to find various scripts in the scripts folder that you can upload to your meshcentral server and push out to agents ad hoc or on a schedule basis. To upload script copy the script, click on a node were the meshagent is installed click on plugins then click on new. Name the script and give it the correct file extension. Then paste in the script and hit save. Right now there are some issues with this plugin and you might have to edit the script, paste it in and hit save multiple times. 