# SMART
SMART reports the status of various hard drive metrics.
Shiftmon's Telegraf role will detect if a Linux machine is running on bare metal or not using the `ansible_facts['virtualization_role'] != 'guest'`.
Unless `deploy_smart: false` is set in host variables Shiftmon will attempt to install smartmontools and nvme-cli in addition to adding the Telegraf config for monitoring SMART.


for some of the some of the information required by smartmon tools you will be
