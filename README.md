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

### Setup the admin user for Meshcentral

### Run the playbook with the Influxdb key

### Upload and Tweak scripts 

