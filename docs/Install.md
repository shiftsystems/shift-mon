## Requirements
* Ubuntu with 23.10 or later. Ubuntu 22.04 will work with `container_engine: docker` in the playbook
* A Redhat 8 or 9 based distro (Alma, Rocky)
* The Current version of Fedora
* 4 subdomains to point at the server
* Debian 12 or later. Will work on Debian 11 with `container_engine: docker` in the playbook

## Installation

### Setup Ansible on your machine

### Ubuntu
1. ```sudo add-apt-repository ppa:ansible/ansible sudo apt update && sudo apt install ansible git python3-apt software-properties-common```


### RedHat and RedHat Derivatives
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
  children:
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
          email: '{{ lookup('env', 'LETSENCRYPT_EMAIL') }}'
        
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
          # username and password telegraf should use to authenticate to victoriametrics
          user: telegraf
          password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          # URL telegraf should use to send metrics to victoriametrics
          url: 'https://metrics.local.example.com'
          domain: metrics.local.example.com
          retention_period: 90d
          # OPTIONAL list strings that can be used to authenticate to shiftmon
          tokens:
            - token1
            - token2
          ## OPTIONAL
          # Bring your own SSL cert
          #cert_path: "{{ playbook_dir }}/files/victoria.crt"
          #key_path: "{{ playbook_dir }}/files/victoria.key"
          # Provision recording rules for storing metrics from commonly used queries like SLOs must end in .yaml or .yml to be evaluated
          rule_files:
            blackbox: /path/to/blackbox.yaml
            pango: /path/to/pango-rules.yml
          # Used for bring you own SSL and if you have devices that do not support SSL
          #insecure: true

        # Grafana is a GUI for viewing your logs and metrics using graphs
        grafana:
          domain: grafana.local.example.com

          ## OPTIONAL
          # Bring your own SSL cert
          #cert_path: "{{ playbook_dir }}/files/grafana.crt"
          #key_path: "{{ playbook_dir }}/files/grafana.key"
          # Path to YAML File which contains Grafana Alerts
          #abert_path: "{{ playbook_dir }}/user-alerts.yml"
          # Dictionary of folders with your own dashboards you want to provision with shiftmon
          #dashboard_paths:
            #business: "{{ playbook_dir }}/business"
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

###### TSDB Date

If you are just installing Shiftmon please set `tsdb_13_date` the date you are deploying Shiftmon formatted `yyyy-mm-dd` This will be the default in the future.

```yaml
tsdb_13_date: 2024-04-10
```

Loki is moving to using the TSDB index and depcrecating the default boltdb index since the TSDB index is performant and they were struggling to maintain all the older indices. To take advantage of these features set `tsdb_13_date` to a date in future formatted `YYYY-MM-DD` this can be used with the existing `tsdb_date` and is a legacy variable which is uses an older schema with the TSDB index.

```yaml
          tsdb_date: "2023-04-30"
          tsdb_13_date: "2024-04-01"
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

          # Optional List of space separated domains for deploying 
          allowed_domains: 'example.com example.net'
```

###### Bring Your Own Dashboards
You can define a dictionary in the shiftmon.yml file that will deploy dashboards you have exported from Grafana
The dictionary name is `dashboard_paths` under `grafana`
The key is the folder name it will appear under in Grafana
The value is the path to the folder on the Ansible Controller
```yaml
grafana:
  domain: "grafana.example.com"
  dashboard_paths:
    business: "{{ playbook_dir }}/business"
```
You can export Grafana dashoards by following the [Grafana docs](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#dashboard-json-model).
4. Deploy or update Shift-mon by running `ansible-galaxy collection install --force shiftsystems.shift_mon  && ansible-playbook -i shift-inventory.yml shift-mon.yml --ask-become-pass` from `~/shift-mon`


5. Setup the Admin User for Grafana
First, navigate to the URL you defined for Grafana and click get started.
Then fill out your username and password. You should do this even if you have ldap enabled to avoid someone creating the admin account on your behalf.


### Deploying Telegraf. 
For Linux Devices Please use the ansible roles. There is a shell script but it does not do nearly as much as the Ansible Role. For other Operating systems, you will find various scripts in the Scripts folder that you can upload to your RMM and push out telegraf on an ad hoc or scheduled basis.

By default the username and password for loki and Victoriametrics are stored in `/etc/default/telegraf` if you want to use linux kernel secrets you can set `use_telegraf_secrets: true` but you will need to apply secrets after every reboot since Linux kernel secrets do not persist across reboots.

By default the Telegraf Ansible role will try to instrument the following services automatically if found on a system.

* adguardhome
* crowdsec
* caddy
* docker
* httpd (apache web server)
* keepalived
* libvirt
* loki
* meshagent (meshcentral client)
* mysql
* nginx
* podman
* victoriametrics
* zfs

Services are discovered by looking at the list of systemd services present on a system or looking for a binary.
If you add one of the supported services to your system just rerun the Telegraf role and the appropriate Telegraf config will be added.
To prevent automatic instrumentation for a service from occurring add a variable called `do_not_instrument: []` to your inventory with the services you do not want shift-mon to instrument from the list above in the form of a list ex `do_not_instrument: ["mysql","docker"]` will not instrument mysql and docker but instrument everything else.
`do_not_instrument: ["docker"]` will not instrument docker automatically, and even though it is 1 item it still needs to be a list.
This variable can be defined as a host variable, group variable or globally.
Defining this variable WILL NOT cause a previously deployed configurations to be removed and the user will have to remove the configuration file from `/etc/telegraf/telegraf.d` and restart telegraf to stop further collection of data from the now ignored service.

By default Telegraf runs as an unprivileged user if you are running into issues with telegraf not having the right permissions to collect certain data please change group membership, permissions on a resource, or add the required capabilities to the telegraf user.
Telegraf can be run as root on your system by setting `telegraf_root: true` in your inventory for that host or group if needed, but this is a security risk since telegraf can run arbitrary scripts using the exec and execd plugins

### [Pushing Telegraf to Linux hosts via Ansible or shell script](docs/Telegraf/Linux.md)


### [Pushing Telegraf to Windows and Linux Endpoints via MeshCentral](docs/Telegraf/Windows.md)
This should a be a similar workflow to most RMMs. upload the scripts, change your particulars, and yeet it on to your endpoints


### Syslog
Shift-mon can configure syslog forwarding to loki, and configure telegraf act a syslog server by following the instructions below

* If `syslog` is defined at all for a host, group, or telegraf will listen for syslog messages on udp port 6667 on localhost.
* Define `syslog: rsyslog` to have the telegraf role install and configure rsyslog and setup log forwarding to udp 6667 on localhost.
* Define `remote_syslog: true` to have telegraf listen for syslog on all interfaces on udp port 6666 not this will only work for syslog formatted in RFC3164.

To ship syslog messages formatted using RFC3164 please configure rsyslog or syslog-ng to forward the logs to telegraf on localhost.
ESXI hosts prior to 8.0 use this format as well as PFSense by default, but PFSense can be configured to use RFC5424 formatting for syslog messages.



### Vsphere
Telegraf can be configured to gather metrics from VCenter by scraping the metrics API to enable this feature add the following variables to a host in your inventory.
```yaml
vsphere_enabled: true
vsphere_urls = ["https://muh-vcenter.local.example.com"]
vsphere_user = "test@example.local.com"
vsphere_password = "SECRET"
```
The vsphere connection information above is saved in /etc/default/telegraf to avoid it being world readable.
The configuration deployed by shift-mon or this WILL NOT collect metrics about each VM in VCenter to avoid running into limitations with the VCenter API.
If you need to increase the amount results the VSphere API will return review [this document](https://kb.vmware.com/s/article/2107096)


## Installing Telegraf on Other Devices

### [Proxmox](Telegraf/Proxmox.md)
Documentation for insturmenting Proxmox Virtual Environment can be found [here](Telegraf/Proxmox.md)

### [Pfsense](docs/Telegraf/PFSense.md)
First, login to your Pfsense firewall as an administrative user.
Next, click on system > package manager then click on available packages.
Type Telegraf in the search box, then click on the install button next to were it says Telegraf.
Click on the confirm and wait for the package to install.
After Telegraf is installed, click on services > Telegraf
Tick the box were it says enable Telegraf and paste in the contents of telegraf_ips.conf. If you are using Snort and have blocking turned use the telegraf_ips.conf. If you are using it for just intrusion detection or not using Snort at all, use telegraf_ids.conf.
Change influxdb.example.com to your InfluxDB domain, replace GET_A_TOKEN_FROM_YOUR_INFLUXDB_INSTANCE with write access to the Pfsense bucket, and click save.
If you are not sure how to get a token, please refer to the Generate Additional Tokens for Each Bucket section of this document


### [OPNSense](docs/Telegraf/OPNSense.md)
