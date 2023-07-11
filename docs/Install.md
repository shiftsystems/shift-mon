## Requirements
* Ubuntu 22.04
* A Redhat 8 or 9 based distro (Alma, Rocky)
* The Current version of Fedora
* 4 subdomains to point at the server
* As of Debian 11 there is not a good way of installing podman >4.0

## Installation

### Setup Ansible on your machine

### Ubuntu
1. ```sudo add-apt-repository ppa:ansible/ansible sudo apt update && sudo apt install ansible git python3-apt software-properties-common```


### RedHat and RedHat Derivitaves
1. ```sudo dnf install epel-release```
2. ```sudo dnf install ansible git ansible```


### Prepping Ubuntu Targets
You will need to run the following commands on a debian machine before running ansible. Since python3, python3-apt, and gpg are not included in some minimal installs
```sudo apt install python3 python3-apt gpg```

### Setup Inventory
1. Make folder in your home directory for shift-mon and the inventory files `mkdir -p ~/shiftmon` or create a `.yml` or `.yaml` file called `shift-inventory.yml` in your existing repository.
2. Add the following to `~/shift-mon/shift-inventory.yml`

```yaml
all:
  hosts:
  childen:
    shiftmon_servers:
      hosts:
        server.local.example.com:
```


3. Create a edit shift-mon.yml with the following Template
If don't have a secretes manager can place the variables in quotes however this is insecure since secrets to various services are in plain text.


#### Configuring Your playbook.yml File

##### Required playbook.yml

Below is an example playbook.yml. It has only what is required to get a basic shift-mon system running.
There are additional features that you can enable by adding to this playbook.yml file. They are listed below.

The example playbook.yml below expects many variables to be defined in the environment it runs in. This can be accomplished in many ways, sourcing a `.env` file before running shift-mon or by using CI or other automation tools that handle secrets automatically.

I'll put this here as a reference to anyone who doesn't know how the ansible.builtin.env works.
Below you will see many lines that look like this. There are two main things to look at in these lines. In our example `CONTAINER_ENGINE` is the expected variable name that you need to add to your environment and `default='podman'` is the default value if you did not supply one. Note that do to the nature of most of these values they won't have a default and the playbook will error if they are not supplied.
```yml
"{{ lookup('ansible.builtin.env', 'CONTAINER_ENGINE', default='podman') }}"
```

```yaml
- hosts: shiftmon_servers
  tasks:
    - name: Set Secrets
      ansible.builtin.set_fact:
        # Sets what container engine you want to use. 
        # Note if the selected container engine is not present it will be installed.
        container_engine: "{{ lookup('ansible.builtin.env', 'CONTAINER_ENGINE', default='podman') }}"
        
        # The email given to LetsEncrypt to issue your SSL certificate.
        tls:
          email: 'you@example.com' # This should be an env Tiny Look at this!
        
        # Users 
        users: # dictionary of users and their password
          telegraf: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          
          ## OPTIONAL
          # Enable this if you are using fleet yeet
          # fleet_yeet: "{{ lookup('env', 'FLEET_PASSWORD') }}"

        # Loki Is What Collects Logs And Makes Them Searchable Via Grafana
        loki:
          user: telegraf
          password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          url: 'https://logs.local.example.com'
          domain: logs.local.example.com
          retention_period: 90d

          ## OPTIONAL
          # Bring your own SSL cert
          #cert_path: "{{ playbook_dir }}/files/loki.crt"
          #key_path: "{{ playbook_dir }}/files/loki.key"

          # Used for bring you own SSL and if you have devices that do not support SSL
          #insecure: true
        
        # Victoria Metrics is the metrics collector, it indexes and stores all metrics for shift-mon
        victoria:
          user: telegraf
          password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          url: 'https://metrics.local.example.com'
          domain: metrics.local.example.com
          retention_period: 90d

          ## OPTIONAL
          # Bring your own SSL cert
          #cert_path: "{{ playbook_dir }}/files/victoria.crt"
          #key_path: "{{ playbook_dir }}/files/victoria.key"
          
          # Used for bring you own SSL and if you have devices that do not support SSL
          #insecure: true
        
        # Grafana is a GUI for viewing your logs and metrics using graphs
        grafana:
          domain: grafana.local.example.com

          ## OPTIONAL
          # Bring your own SSL cert
          #cert_path: "{{ playbook_dir }}/files/grafana.crt"
          #key_path: "{{ playbook_dir }}/files/grafana.key"
        
        # Ansible variables
        ansible_remote_tmp: /tmp
        ansible_ssh_common_args: '-o StrictHostKeyChecking=no'

        ###########################
        #
        # Paste optional feature variables here
        #
        ###########################


    - name: Deploy Telegraf
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.telegraf
        public: true
    - name: Deploy Uptime-Kuma
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.uptime_kuma
        public: true
    - name: Deploy Victoriametrics
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.victoriametrics
        public: true
    - name: Deploy Loki
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.loki
        public: true
    - name: Deploy Grafana
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.grafana
        public: true
    - name: Deploy Traefik
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.traefik
        public: true
    - name: Deploy Crowdsec
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.crowdsec
        public: true
    - name: Deploy Podman
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.podman
        public: true
```

##### Additional Optional Features

You can copy and paste these groups of variables to enable additional features of shift-mon.

###### Email
```yaml
        # SMTP information to allow Grafana to send emails
        email:
          #enabled: true # Set this to true to enable email 
          host: 'mail.example.com'
          alert_from_address: 'alerts@example.com'
          user: 'alerts@example.com'
          password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          alert_from_name: 'Shiftmon Alerts'
          port: '587'
```

###### Grafana Oncall
```yaml
        oncall_enabled: true
        oncall:
          secret: "{{ lookup('env', 'ONCALL_SECRET') }}"
          domain: "oncall.local.example.com"

          ## OPTIONAL
          # Bring your own SSL cert
          #key_path: "{{ playbook_dir }}/files/oncall.key"
          #cert_path: "{{ playbook_dir }}/files/oncall.crt"
```

###### Uptime Kuma
```yaml
        uptime_kuma_enabled: true
        uptimekuma:
          domain: uptime-kuma.local.example.com

          ## OPTIONAL
          # Bring your own SSL cert
          #cert_path: "{{ playbook_dir }}/files/uptime-kuma.crt"
          #key_path: "{{ playbook_dir }}/files/uptime-kuma.key"
```

###### Only Use This If You Know What Your Doing!

For existing install without this variable set or your log db will get corrupted.

```yaml
          tsdb_date: "2023-04-30"
```

###### NOT SURE (Tiny look at this!)
```yaml
        # set to rsyslog to install and configure rsyslog and the config for telegraf. set to false or comment out to not touch syslog
        syslog: rsyslog
        remote_syslog: true 

```

###### Croudsec
```yaml
        # set to true to setup an RFC5424 syslog server on UDP port 6666
        crowdsec_api_key: 'GET_IT_FROM_CROWDSEC'

```

###### LDAP Authentication
```yaml
        ldap_host: 'ldap.example.com'
        ldap_port: '389' # use 636 for SSL use 389 for STARTTLS and please don't use plain text
        bind_dn: 'uid=grafana_bind,cn=users,cn=accounts,dc=local,dc=example,dc=com'
        base_dn: 'dc=local,dc=shiftsystems,dc=net'
        user_search: '(\u0026(uid=%s)(memberOf=cn=ipausers,cn=groups,cn=accounts,dc=local,dc=example,dc=com))'
        ldap_first_name: 'givenName'
        member_of: 'memberOf'
        ldap_last_name: 'sn'
        ldap_user: 'uid'
        ldap_email: 'mail'
        admin_group: 'cn=admins,cn=groups,cn=accounts,dc=local,dc=example,dc=com'
        # bind_password: "{{ lookup('env', 'BIND_PASSWORD') }}" # optional LDAP Bind Password
```

###### OIDC Authentication
```yaml
        oauth:
          auth: true
          name: "The name you want to show up on Grafana login page"
          client_id: "{{ lookup('env', 'OIDC_CLIENT_ID')}}"
          client_secret: "{{ lookup('env', 'OIDC_CLIENT_SECRET')}}"

          # You will find auth_url, token_url and api_url in the docs of your OIDC provider. 
          auth_url: 'https://oidc.example.com/login/oauth/authorize'
          token_url: 'https://oidc.example.com/login/oauth/access_token'
          api_url: 'https://oidc.example.com/login/oauth/userinfo'

          # These should be fine but also check your OIDC provider's documentation.
          scope: 'openid profile email'

          # NOT SURE (Tiny look at this!)
          allowed_domains: 'example.com example.net'
```

4. Deploy or update Shift-mon by running `ansible-galaxy collection install --force shiftsystems.shift_mon  && ansible-playbook -i shift-inventory.yml shift-mon.yml --ask-become-pass` from `~/shift-mon`


5. Setup the Admin User for Grafana
First, navigate to the URL you defined for Grafana and click get started.
Then fill out your username and password. You should do this even if you have ldap enabled to avoid someone creating the admin account on your behalf.


### Deploying Telegraf. 
For Linux Devices Please use the ansible roles. There is a shell script but it does not do nearly as much as the Ansible Role. For other Operating systems, you will find various scripts in the Scripts folder that you can upload to your RMM and push out telegraf on an ad hoc or scheduled basis.


### [Pushing Telegraf to Linux hosts via Ansible or shell script](docs/Telegraf/Linux.md)


### [Pushing Telegraf to Windows and Linux Endpoints via MeshCentral](docs/Telegraf/Windows.md)
This should a be a similar workflow to most RMMs. upload the scripts, change your particulars, and yeet it on to your endpoints


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
