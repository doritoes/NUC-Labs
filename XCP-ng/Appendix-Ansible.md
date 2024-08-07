# Appendix - Ansible Configuring Check Point Lab
This appendix follows the next steps after completing [Appendix - Terraform and XCP-ng](Appendix-Terraform.md). Now that the VMs are created, it's time to prepare them for the next step, configuring and managing using Ansible.

Notes:
- The Linux-based VM templates have the user `ansible` created. SSH with RSA keys still needs to be enabled.


# Configure Management Workstation

# Configure VyOS Router
- Log back in
  - use loadkeys in Op mode
~~~
vyos@vyos-rtr:~$ configure
vyos@vyos-rtr# set system login user jsmith full-name "John Smith"
vyos@vyos-rtr# set system login user jsmith authentication plaintext-password examplepassword
vyos@vyos-rtr# set system login user jsmith level admin
vyos@vyos-rtr# commit
vyos@vyos-rtr# save

pc1 = 192.168.0.3 (linux) username = user1
vyos = 192.168.0.101 (version 1.1.8) username = user1

login to vyos
switch to configuration mode
type the command: loadkey user1 scp://user1@192.168.0.3/home/user1/.ssh/id_rsa.pub
~~~
configure router using ansible

# Configure SMS
- set IP information
- set hostname
- configure ansible SSH RSA keys
- configure FTW using ansible

# Configure Branch 1

## Configure Branch 1 firewalls
- Initial settings
  - set IP information
  - set hostname
  - configure ansible SSH RSA keys
- FTW using Ansible
- Gaia config
- Create cluster
- policy
- DHCP helper in DMZ
- Move management workstation to Branch 1 LAN

## Configure DMZ Servers
Set up NAT and rules

IIS and Apache

## HTTPS Inspection
- HTTPS inspection

# Configure Branch 2
- Initial settings
- FTW
- Gaia config
- Create cluster
- policy
- VPN tunnel bring up
- DHCP helper?????

# Configure Branch 3
- Initial settings
- FTW
- Gaia config
- Create cluster
- policy
- VPN tunnel bring up
- DHCP helper?????

