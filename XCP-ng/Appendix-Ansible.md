# Appendix - Ansible Configuring Check Point Lab
This appendix follows the next steps after completing [Appendix - Terraform and XCP-ng](Appendix-Terraform.md). Now that the VMs are created, it's time to prepare them for the next step, configuring and managing using Ansible.

Notes:
- The Linux-based VM templates have the user `ansible` created. SSH with RSA keys still needs to be enabled.

# Build the Environment using Terraform
- `terraform plan`
- `terraform apply -auto-approve`

# Configure Management Workstation
- From XO, click on `mananger`
  - Note the network is configured for two interfaces
    - First one: `Pool-wide network associated with eth0`
      - allows downloading and installing software and packages
      - will be desabled after Branch 1 configuration is complete, or completely removed
    - Second one: `branch1mgt`
- Optionally, from the app store install "Windows Terminal" by Microsoft
  - this makes it easy to switch between CMD, Powershell, and WSL
- Rename the PC as `manager`
  - From administrative powershell
    - `Rename-Computer -NewName manager`
    - `Restart-Computer`
- Install WSL
  - **Start** > **Settings** > **Add an optional feature**
  - Click **More Windows features**
  - Check **Windows Subsystem for Linux**
  - Click **OK**
  - Click **Restart now**
  - Log back in and open privileged shelll
    - `wsl list`
    - `wsl --list --online`
    - `wsl --install -d Ubuntu-22.04`
      - feel free to customize
      - Enter the username (e.g., `ansible`) and password to use
- Configure Network interfaces
  - Settings > Network & Internet
  - Click Ethernet > First Interface (connected)
    - Network profile: Private
  - Click Ethernet > Second Interface (No Internet)
    - IP assigment: Click **Edit**
    - From dropdown select Manual
    - Slide to enable **IPv4**
      - We cannot set the IP address without a gateway IP or DNS from this interface!
  - Settings > Network & Interface > Ethernet
    - Click Change adapter options
    - Open the adapter (i.e., **Ethernet 3**) with "Unidentified network"
    - Click **Properties**
    - Change to "Use the following IP address"
      - Use the following IP address:
        - IP address: 192.168.41.100*
        - Subnet mask: **24**
        - Gateway: **192.168.41.1**
        - Leave DNS entries empty
        - Click OK
      - Click OK
    - Click Close
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

