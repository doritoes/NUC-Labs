# Appendix - Ansible Configuring Check Point Lab
This appendix follows the next steps after completing [Appendix - Terraform and XCP-ng](Appendix-Terraform.md). Now that the VMs are created, it's time to prepare them for the next step, configuring and managing using Ansible.

Notes:
- The Linux-based VM templates have the user `ansible` created. SSH with RSA keys still needs to be enabled.

# Build the Environment using Terraform
- `terraform plan`
- `terraform apply -auto-approve`

# Configure Management Workstation
- From XO, click on `manager`
  - Note the network is configured for two interfaces
    - First one: `Pool-wide network associated with eth0`
      - allows downloading and installing software and packages
      - will be disabled (or completely removed) after Branch 1 configuration is complete
    - Second one: `branch1mgt`
- Log in to the console of `manager`
- Optionally, from the app store install "Windows Terminal" by Microsoft
  - this makes it easy to switch between CMD, Powershell, and WSL shells
  - Open Microsoft Store, update it if required
  - Install **Windows Terminal**
  - Open Terminal and note the dropdown to select which terminal(s) you want to open
- Rename the PC to `manager`
  - From administrative powershell
    - `Rename-Computer -NewName manager`
    - `Restart-Computer`
- Install WSL
  - Add optional feature Windows Subsystem for Linux (WSL)
    - NOTE In Lab testing, skipping this step caused problems
    - Start > type "Add an optional feature", click it
    - Scroll to bottom, click **More Windows features**
    - Check **Windows Subsystem for Linux** and click **OK**
    - Click **Restart now**
  - Log back in and open a privileged shell
    - `wsl --list`
    - `wsl --list --online`
    - `wsl --install -d Ubuntu-22.04`
      - feel free to customize
      - A new WSL window is opened and you are promped set the username and password
        - Username: `ansible`
        - NOTE if it sticks at *Installing, this may take a few minutes...*, <ins>press Control-C and it will continue</ins>, prompting you to set the username and password
- Configure Network interfaces
  - **Settings** > **Network & Internet**
  - **Click Ethernet** > **First Interface** (connected)
    - Network profile: **Private**
  - Click **Ethernet** > **Second Interface** (No Internet)
    - IP assigment: Click **Edit**
    - From dropdown select **Manual**
    - Slide to enable **IPv4**
      - We cannot set the IP address without a gateway IP or DNS from this interface!
  - Click **Start** > **Settings** > **Network & Interface** > **Ethernet**
    - Click **Change adapter options**
    - Open the adapter (i.e., **Ethernet 3**) with "Unidentified network"
    - Click **Properties**
    - Double-click **Internet Protocol Version 4** (TCP/IPv4)
    - Change to "Use the following IP address"
      - Use the following IP address:
        - IP address: **192.168.41.100**
        - Subnet mask: **255.255.255.0**
        - Gateway: Leave empty
        - Leave DNS entries empty
        - Click **OK**
      - Click **OK**
    - Click **Close**
- Install additional Windows applications
  - [Chrome browser](https://www.google.com/chrome/)
  - [WinSCP](https://winscp.net/eng/download.php)
- This is a good time to change your display resolution to 1440 x 900 or your resolution of choice
- Install additional WSL packages
  - `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`
  - `sudo apt install -y software-properties-common python3-paramiko python3-pip`
  - Install Ansible
    - Option 1 - recommended - Ansbile 2.17 (or later)
      - `sudo apt-add-repository ppa:ansible/ansible`
      - `sudo apt update && sudo apt install -y ansible`
      - `ansible --version`
      - Normally installing with ppa method is discouraged; this is is easiest way to get current ansible for automation
    - Option 2 - Ubuntu 22.04 old Ansible 2.10
      - `sudo apt install -y ansible`
      - `ansible --version`
  - Install ansible collections
    - `ansible-galaxy collection install community.general vyos.vyos check_point.mgmt check_point.gaia`
    - `ansible-galaxy collection install check_point.mgmt --force`
  - Install XenAPI python package
    - `python3 -m pip install XenAPI`
- Generate ssh RSA key for user `ansible`
  - Open WSL terminal (Start > search WSL, or open Windows Terminal and click the dropdown carrot and click Ubuntu)
  - `ssh-keygen -o`
    - <ins>Do not</ins> enter a passphrase
    - Accept all defaults (press enter)
  - The public key you will be using:
    - `cat ~/.ssh/id_rsa.pub`
- Set up basic configuration files for Ansible
  - Create `ansible.cfg` from [ansible.cfg](ansible/ansible.cfg)
  - Create `inventory` from [inventory](ansible/inventory)
    - Note the values are commented out; we will confirm and enable these IPs later in the Lab
    - Under `[router]` you will put the Lab IP address of the router
      - This will be configured in the next step
      - And yes, the simulated Internet IP; the inside interface won't be accessible until later

# Configure VyOS Router
- Open the `vyos` router VM and log in to console
- Configure eth0 interface
  - `configure`
  - `set interfaces ethernet eth0 address dhcp`
  - `set service ssh`
  - `commit`
  - `save`
  - `exit`
  - Get the IP address on eth0
    - `show interfaces ethernet eth0 brief`
- From `manager` VM configure key login in VyOS
  - Log in to VyOS as `ansible`
    - `ssh ansible@<vyos_lab_ip>`
    - accept the key
    - log in with password
  - `configure`
  - `set system login user ansible authentication public-keys home type 'ssh-rsa'`
  - `set system login user ansible authentication public-keys home key '<valueofkey>'`
    - paste in contents of the id_rsa.pub file on manager <ins>without the leading `ssh-rsa`</ins>
  - `commit`
  - `save`
  - `exit`
- Test Ansible access
  - `exit`
  - Retry: `ssh ansible@<vyos_lab_ip>`
    - no longer requies a password
  - Edit the `inventory` files to add the IP address of the router below `[router]`
  - the `inventory` files should have the VyOS "public" IP without the "#" comment character
  - everything else should be "commented out"
  - `ansible all -m ping`
  - You are expecting `SUCCESS` and `"ping": "pong"`
- Configure router using Ansible
  - Create router.yml from [router.yml](ansible/router.yml)
  - `ansible-playbook router.yml`
  - Testing
    - Login in to the VyOS router
    - `show interfaces`
    - Spin up a temporary VM based on template `win10-template` on the **build** network
      - it should be get DHCP information and be able to connect to the Internet

# Configure SMS
Steps:
- In XO, select the VM `SMS`
- Under Network tab, set the network interface settings to disable TX checksumming
- Log in to console of SMS
  - Username `admin` and the password you selected
- Set IP address information
  - `set interface eth0 ipv4-address 192.168.41.20 mask-length 24`
  - `save config`
- Log in to `manager` and open a WSL shell
  - `ssh ansible@192.168.41.20`
    - you will be in the default home directory `/home/ansible`
- Create new authorized_keys file and add the key
  - `mkdir .ssh`
  - `chmod u=rwx,g=,o= ~/.ssh`
  - `touch ~/.ssh/authorized_keys`
  - `chmod u=rw,g=,o= ~/.ssh/authorized_keys`
  - Add the public key from `manager` to the files
    - `cat > ~/.ssh/authorized_keys`
      - paste in the key
      - press Control-D
  - `exit`
  - You can now ssh without a password
    - `ssh 192.168.41.20`
- Test Ansible access
  - Exit back to session on manager
  - update file `inventory`, uncomment to IP of the SMS 192.168.41.20
    - leave the variable intact
  - `ansible all -m ping`
    - You are expecting `SUCCESS` and `"ping": "pong"` for 192.168.41.20
    - the router should also respond `SUCCESS`
- Create files on the manager (variables file, playbook to create SMS, and the jinja template for the SMS)
  - [vars.yml](ansible/vars.yml)
  - [sms.yml](ansible/sms.yml)
  - [sms.j2](ansible/sms.j2)
  - [sms-user.j2](ansible/sms-user.j2)
- Run the playbook to complete the first time wizard (FTW), reboot, and add the user "ansible" to the SMS's managment database
  - `ansible-playbook sms.yml`
    - This takes a long time
    - Uses `config_system` tool to perform FTW
    - Creates user `ansible` using `mgmt_cli`
      - Creating the user directly using the ansible module `add-administrator` isn't working correctly as of this writing
    - Allows all IP addresses to connect to the API in our Lab environment
  - Testing
    - Log in to `sms` console (or ssh)
      - `fwm ver`
      - Should say *Check Point Management Server R81.20*
    - `api status`
- Log in to `sms` Web gui from `manager`
  - https://192.168.41.20
  - Download the SmartConsole R81.20 client using the link "Download Now!"
- Install SmartConsole using the downloaded file
- Launch SmartConsole
  - Username: `cpadmin`
  - Password: *the password from vars.yml (default Checkpoint123!)*
  - Server Name or IP Address: **192.168.41.20**
  - Accept the server identity and click **Proceed**
  - After a short time, the SmartConsole app will prompt you to click **Relaunch Now** to apply the latest updates
    - In Lab testing sometimes a pop-up error appeared after trying to launch while staying logged in
      - "Application has experienced a serious problem and must close immediately"
      - Click **OK** and continue using the application normally
- Update Gaia (if you have proper eval licenses)
  - Wait until the Branch 1 firewalls are configured and providing Internet access
  - A valid license is required for downloads and updates (the 15-day trial license does not meet this requriement); however once Internet access is working, you can use CPUSE to apply jumbo hotfixes
  - SMS updates are best applied manually (whereas firewalls are updated using management API)
    - clish
      - installer check-for-updates
      - installer download [tab]
      - installer install [tab]
    - Web GUI > Upgrades (CPUSE)
- Create objects in the Check Point database related to management
  - Create files on the manager (inventory, playbook)
    - [inventory-api](ansible/inventory-api)
      - Customize to update the credentials as needed
      - Lab testing to move the login credentials to the playbook was not successful in Ansibile 2.10.8
      - Starting Ansible 2.11, use new `include_vars` to include the var.yml and use the credentials from there
    - [management-objects.yml](ansible/management-objects.yml)
  - `ansible-playbook -i inventory-api management-objects.yml`
  - In SmartConsole press Control-E to open the Object explorer
    - Expand Network Objects
    - Note that the new hosts and network appear when you select Networks and/or Hosts 

Note:
- To reset and re-run the FTW on this management server, remove the following files:
  - `/etc/.wizard_accepted`
  - `/etc/.wizard_started`
  - `$FWDIR/conf/ICA.crl`
  - `$FWDIR/conf/InternalCA.*`

References:
- https://galaxy.ansible.com/ui/repo/published/check_point/mgmt/
- https://docs.ansible.com/ansible/latest/collections/check_point/mgmt/cp_mgmt_checkpoint_host_module.html#examples
- https://www.youtube.com/watch?v=fx1KMtuBHWs

# Configure Branch 1
The following steps configure Branch 1
## Configure Branch 1 firewalls
Steps:
- BEFORE you POWER ON the firewalls **firewall1a** and **firewall1b**
  - Turn off TX checksumming on each interface
  - Click Network tab
  - For each interface click the blue gear and click to set TX checksumming **Disabled**
- Power on **firewall1a** and **firewall1b**
- Log in to consoles of **firewall1a** and **firewall1b**
  - Username `admin` and the password you selected
- Set IP address information
  - firewall1a
    - `set interface eth0 ipv4-address 192.168.41.2 mask-length 24`
    - `save config`
  - firewall1b
    - `set interface eth0 ipv4-address 192.168.41.3 mask-length 24`
    - `save config`
- Add `manager`'s RSA keys to each firewall's authorized_keys file
  - Log in to `manager` and open a WSL shell
    - ssh to firewall1a and firewall1b
      - `ssh ansible@192.168.41.2`
      - `ssh ansible@192.168.41.3`
      - you will be in the default home directory `/home/ansible`
  - Create new authorized_keys file and add the key
    - `mkdir .ssh`
    - `chmod u=rwx,g=,o= ~/.ssh`
    - `touch ~/.ssh/authorized_keys`
    - `chmod u=rw,g=,o= ~/.ssh/authorized_keys`
    - Add the public key from `manager` to the files
      - `cat > ~/.ssh/authorized_keys`
        - paste in the key
        - press Control-D
    - `exit`
  - You can now ssh without a password
- Test Ansible access
  - Exit back to session on `manager`
  - update file `inventory`, uncomment the IPs of firewall1a (192.168.41.11) and firewall1b (192.168.41.12)
  - `ansible all -m ping`
    - You are expecting `SUCCESS` and `"ping": "pong"` for both firewalls
- Create files on the manager (variables file, playbook to create SMS, and the jinja template for the SMS)
  - [firewall1a.yml](ansible/firewall1a.yml)
  - [firewall1a.cfg](ansible/firewall1a.cfg)
  - [firewall1b.yml](ansible/firewall1b.yml)
  - [firewall1b.cfg](ansible/firewall1b.cfg)
  - [branch1.j2](ansible/branch1.j2)
- Run the playbooks to complete the first time wizard (FTW) and reboot
  - `ansible-playbook firewall1a.yml`
  - `ansible-playbook firewall1b.yml`
- Test
  - You should still be able to connect to the web GUI from `manager`
  - https://192.168.41.2
  - https://192.168.41.3
- Update Gaia (if you have proper eval licenses)
  - A valid license is required for downloads and updates (the 15-day trial license does not meet this requriement)
  - Firewalls are best updated using the management API
- Create objects in the Check Point database related to Branch 1
  - Create file on `manager`
    - [branch1-objects.yml](ansible/branch1-objects.yml)
  - `ansible-playbook -i inventory-api branch1-objects.yml`
- Create cluster using API
  - https://galaxy.ansible.com/ui/repo/published/check_point/mgmt/content/module/cp_mgmt_simple_cluster/
  - Create file on `manager`
    - [firewall1-cluster.yml](ansible/firewall1-cluster.yml)
  - `ansible-playbook -i inventory-api firewall1-cluster.yml`
- Create new policy using API
  - [branch1-policy.yml](ansible/branch1-policy.yml)
    - 🌱 still working on policy
      - allow management (RDP, SSH) to DMZ servers
      - noise supporession rules like multicast
        - udp 1900 to 239.255.255.250
        - 224.0.0.2???
    - `ansible-playbook -i inventory-api branch1-policy.yml`
- Push policy
  - [branch1-push.yml](ansible/branch1-pish.yml)
    - `ansible-playbook -i inventory-api branch1-push.yml`
- At this point you should be able to install a JHF on the SMS and on the firewalls
  - `installer check-for-udpates`
  - `installer download-and-install [tab]`
  - select the applicable JHF hotfix bundle by number
  - Approve the reboot

## Remove management workstation from the Lab network
Disable lab-connected interface on `manager`, leaving sole connection via Branch 1 Management network
- Start > Settings > Network & Internet > Ethernet
- Click **Change adapter options**
- Configure Ethernet 3 interface
  - Double-click the Ethernet 3 interface, which is connected to the Management network
  - Properties > Internet Protocol Version 4 (TCP/IP/IPv4)
  - Configure default gateway: *8192.168.41.1**
  - Enter DNS servers
    - 8.8.8.8
    - 8.8.4.4
  - Click OK > OK > Close
- Disable Ethernet 2 interface
  - Right-click Ethernet 2
  - Click Disable
- Test Internet connectivity, etc. to confirm it is still working

## Configure Domain Controller
- Open console for DC-1
- Complete initial setup and set administrator password
- Log in for the first time
- Rename server
  - Open administrative powershell
  - `Rename-Computer -NewName dc-1`
  - `Restart-Computer`
- Network configuration
  - Open administrative powershell
  - Set the static IP address and point DNS settings to itself (it's going to be a domain controller).
    - `New-NetIPAddress -IPAddress 10.0.1.10 -DefaultGateway 10.0.1.1 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex`
    - **Yes** allow PC to be discoverable
    - `Set-DNSClientServerAddress -InterfaceIndex(Get-NetAdapter).InterfaceIndex -ServerAddresses 10.0.1.10`
- Promote DC-1 from server to Domain Controller
  - `Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools`
  - `Install-ADDSForest -DomainName xcpng.lab -DomainNetBIOSName AD -InstallDNS`
    - Select a password for SafeModeAdministratorPassword (aka DSRM = Directory Services Restore Mode)
  - Confirm configuring server as Domain Controller and rebooting
  - Wait as the settings are applied and the server is rebooted
  - Wait some more as "Applying Computer Settings" gets the domain controller ready
- Configure Sites and Services Subnets and DNS
  - branch1-site.ps1 ([branch1-site.ps1](ansible/branch1-site.ps1))
  - `powershell -ExecutionPolicy Bypass branch1-site.ps1`
  - 🌱create more DNS entries
  - test using nslookup
    - nslookup google.com
    - nslookup firewall1-lan
    - nslookup firewall1-lan.xcpng.lab
    - nslookup 10.0.1.1
    - nslookup dc-1
    - nslookup 10.0.1.10 (will not resolve yet)
- Configure DC-1 as DHCP server
  - branch1-dhcp.ps1 ([branch1-dhcp.ps1](ansible/branch1-dhcp.ps1))
  - `powershell -ExecutionPolicy Bypass branch1-dhcp.ps1`
  - test
    - `Get-DhcpServerInDC`
    - spin up a test workstation on branch1 subnet
      - confirm it receives an IP address via DHCP
      - test Internet access
  - NOTE Server manager will complain: "Configuration required for DHCP Server at DC-1"
    - You can click on the link to create security groups for delegation of DHCP Server Administration and also authorize DHCP server on target computer. Or find a way to do it with powershell.
- Configure AD users, groups, roles, and permissions
  - copy domain-users.csv [domain-users.csv](ansible/domain-users.csv) to C:\domain-users.csv
  - copy domain-users-groups.ps1 [domain-users-groups.ps1](ansible/domain-users-groups.ps1)
  - `powershell -ExecutionPolicy Bypass C:\domain-users-groups.ps1`
- Configure to use external time server
  - `net stop w32time`
  - `w32tm /config /syncfromflags:manual /manualpeerlist:"time.windows.com"`
  - `w32tm /config /reliable:yes`
  - `net start w32time`
  - `w32tm /query /configuration`
  - `w32tm /resync`
  - `w32tm /query /status`
- Test logging in to the domain controller as `AD\Juliette.Larocco2` and the password from [domain-users.csv](ansible/domain-users.csv)
  - Juliette.Larocco2@xcpng.lab

## Configure LAN devices
- Configure workstation **branch1-1**
  - Log in for the first time at the console
  - Rename workstation
    - Open administrative powershell
    - `Rename-Computer -NewName branch1-1`
    - `Restart-Computer`
  - Join to domain
    - Open administrative powershell
    - `Add-Computer -DomainName xcpng.lab -restart`
      - User name: `AD\Juliette.LaRocco2` (or, XCPNG.LAB\juliette.larocco2)
      - Password: the password you set
  - Testing
    - Log in as Other user > juliette.larocco
      - Note the first time experience for the domain user
      - Try Remote desktop connection to DC-1
        - juliette.larocco fails "Logon failure: the user has not been granted the requested logon type at this computer."
        - juliette.larocco2 fails if "Administrator" is still logged in on DC-1
- Configure file server **file-1**
  - Complete initial setup and set administrator password
  - Log in for the first time at the console
  - **Yes** allow your PC to be discoverable by other PCs and devices on this network
  - Rename server
    - Open administrative powershell
    - `Rename-Computer -NewName file-1`
    - `Restart-Computer`
  - Network configuration
    - Open administrative powershell
    - Set the static IP address and point DNS settings to the domain controller/DNS server
      - `New-NetIPAddress -IPAddress 10.0.1.11 -DefaultGateway 10.0.1.1 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex`
    - `Set-DNSClientServerAddress -InterfaceIndex(Get-NetAdapter).InterfaceIndex -ServerAddresses 10.0.1.10`
    - Try testing nslookup to see what resolves (IPs, FQDN)
  - Install file server feature
    - `Install-WindowsFeature -Name FS-FileServer`
    - Join to domain
      - Open administrative powershell
      - `Add-Computer -DomainName xcpng.lab -restart`
        - User name: `AD\Juliette.LaRocco2` (or, XCPNG.LAB\juliette.larocco2)
        - Password: the password you set
  - Set up share drive and file shares
    - Log in as AD\juliette.larocco2
    - Start > Create and format hard disk partitions
      - You will be prompted to initialize the disk (Disk 1)
      - Accept GPT (GUID Partition Table)
      - Click OK
      - Right-click Disk 1 and then click **New Simple Volume**
      - Assign letter E:
      - Follow the wizard and set the volume label to NETDRIVE
    - copy file-shares.ps1 [file-shares.ps1](ansible/file-shares.ps1)
  - `powershell -ExecutionPolicy Bypass file-shares.ps1`
    - NOTE there are no users in OU=Finance,OU=Corp,DC=xcpng,DC=lab in the provided file; this causes an error when running the script, but the rest is successfully configured
  - Testing
    - test access from `branch1-1` to the shared folders by different domain users
- Configure SQL server **sql-1**
  - Complete initial setup and set administrator password
  - Log in for the first time at the console
  - **Yes** allow your PC to be discoverable by other PCs and devices on this network
  - Rename server
    - Open administrative powershell
    - `Rename-Computer -NewName sql-1`
    - `Restart-Computer`
  - Network configuration
    - Open administrative powershell
    - Set the static IP address and point DNS settings to the domain controller/DNS server
      - `New-NetIPAddress -IPAddress 10.0.1.12 -DefaultGateway 10.0.1.1 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex`
    - `Set-DNSClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses 10.0.1.10`
    - Try testing nslookup to see what resolves (IPs, FQDN)
  - Set up data drive
    - Log in as AD\juliette.larocco2
    - Start > Create and format hard disk partitions
      - You will be prompted to initialize the disk (Disk 1)
      - Accept GPT (GUID Partition Table)
      - Click OK
      - Right-click Disk 1 and then click **New Simple Volume**
      - Assign letter E:
      - Follow the wizard and set the volume label to SQL
  - Join to domain
    - Open administrative powershell
    - `Add-Computer -DomainName xcpng.lab -restart`
      - User name: `AD\Juliette.LaRocco2` (or, XCPNG.LAB\juliette.larocco2)
      - Password: the password you set
  - Install MS SQL server ([more information](https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server?view=sql-server-ver16))
    - Download SQL Server Express: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
      - file name looks like: `SQL2022-SSEI-Expr.exe`
    - Run the installer
      - Click **Basic**
      - Click **Install SSMS**
        - From the web page that opens, download and install SQL Server Management Studio (SSMS)
      - Click **Connect Now** to test
      - Click **Close** and confirm
  - Test
    - Launch SQL Server Management Studio
      - Check **Trust server certificate**
      - Click **Connect**
    - For a production environment, use proper authentication

## Update management workstation to join the domain
- Log in to `manager`
- Confirm Network profile is **Private**
- Edit IP settings to set DNS
  - Preferred DNS: 10.0.1.10
  - Alternate DNS: *blank*
- Join to domain
  - Open administrative powershell
  - `Add-Computer -DomainName xcpng.lab -restart`
    - User name: `AD\Juliette.LaRocco2` (or, XCPNG.LAB\juliette.larocco2)
    - Password: the password you set

## Configure DMZ Servers
- Configure Apache web server **dmz-apache**
  - Configure Static IP address
    - `sudo vi /etc/netplan/01-netcfg.yaml`

```
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.31.11/24
      routes:
        - to: 0.0.0.0/0
          via: 192.168.31.1
      nameservers:
        addresses:
          - 10.0.1.10
```

    - `sudo chmod 600 /etc/netplan/01-netcfg.yaml`
    - `sudo netplan apply`
  - Give permissions to user ansible
    - `echo "ansible ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/dont-prompt-ansible-for-sudo-password"`
  - set up ssh key auth
    - from `manager`
      - `ssh-copy-id 192.168.31.11`
  - Update file `inventory`
    - uncomment dmzserver 192.168.31.11
    - test: `ansible all -m ping`
  - Update hostname and install packages
    - [php.conf](ansible/php.conf)
    - [ss.conf.j2](ansible/ssl.conf.j2)
    - [dmz-apache.yml](ansible/dmz-apache.yml)
    - `ansible-playbook dmz-apache.yml`
  - Testing
      - From branch1-1:
        - https://192.168.31.11
        - http://192.168.101.6
      - From manager: http://192.168.31.11
      - From a test machine on build network: http://192.168.101.6
- Configure IIS web server **dmz-iis**
  - Complete initial setup and set administrator password
  - Log in for the first time at the console
  - **Yes** allow your PC to be discoverable by other PCs and devices on this network
  - Rename server
    - Open administrative powershell
    - `Rename-Computer -NewName dmz-iis`
    - `Restart-Computer`
  - Network configuration
    - Log back in
    - Open administrative powershell
    - Set the static IP address and point DNS settings to the domain controller/DNS server
      - `New-NetIPAddress -IPAddress 192.168.31.10 -DefaultGateway 192.168.31.1 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex`
      - **Yes** allow your PC to be discoverable by other PCs and devices on this network
    - `Set-DNSClientServerAddress -InterfaceIndex(Get-NetAdapter).InterfaceIndex -ServerAddresses 10.0.1.10`
  - Join to domain
    - Open administrative powershell
    - `Add-Computer -DomainName xcpng.lab -restart`
      - User name: `AD\Juliette.LaRocco2` (or, XCPNG.LAB\juliette.larocco2)
      - Password: the password you set
  - Install IIS
    - Open administrative powershell
    - `Install-WindowsFeature Web-Server -IncludeManagentTools`
    - Test:
      - From dmz-iis: http://localhost
      - From branch1-1:
        - http://dmz-iis
        - http://192.168.31.10
        - http://192.168.101.5
      - From manager: http://192.168.31.10
      - From a test machine on build network: http://192.168.101.5
    - You may want to test IIS by using asp.net hello world https://www.guru99.com/asp-net-first-program.html

## HTTPS Inspection
🌱 this needs to be developed
- branch1-https.yml [branch1-https.yml](ansible/branch1-https.yml)
  - creates the certificate
- Non-ansible/manual solutions here since ansible check_point.mgmt doesn't support all the commands until R82
  - creating https rules, etc not supported until R82
  - some outbound certificate commands function differently pre-R82
  - enable-https-inspection will be added in the next version
- Export the certificate using SmartConsole gui
- Enable HTTPS inspection in SmartConsole gui
- Import the certificate on DC-1
  - copy the .cer file to c:\certificate.cer
  - Powershell
    - `Import-Certificate -FilePath "C:\Certificate.cer" -CertStoreLocation "Cert:\LocalMachine\Root"`
    - Note the thumbprint. Save this value for later.
  - verify the import using `certlm.msc`
- 🌱 need to continue here
  
```
PowerShell
# Replace "DomainName" with your actual domain name
$DomainName = "xcpng.lab"

# Replace "OU=Corp,DC=xcpng,DC=lab" with your desired OU
$OU = "OU=Corp,DC=xcpng,DC=lab"

# Specify the path to your certificate file
$CertPath = "C:\Certificate.cer"

# Create a new GPO
$GPO = New-ADGroupPolicy -Name "Distribute Root CA Certificate" -Path "Domains/$DomainName/Organizational Units/$OU"

# Set the GPO to link to the OU
Set-ADGroupPolicy -Identity $GPO -Path "Domains/$DomainName/Organizational Units/$OU"

# Create a new registry key to store the certificate
$RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Certificates"

# Create a new registry value to store the certificate thumbprint
$RegistryValue = "RootCAThumbprint"

# Get the thumbprint of the certificate
$Cert = Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Thumbprint -match "YourCertificateThumbprint"}
$Thumbprint = $Cert.Thumbprint

# Create a new GPO preference to set the registry value
$Preference = New-ADGroupPolicyPreference -Target "Computer" -Action "Create" -KeyPath $RegistryKey -ValueName $RegistryValue -ValueType "String" -ValueData $Thumbprint

# Link the preference to the GPO
Add-ADGroupPolicyPreference -Target $Preference -Path "Domains/$DomainName/Organizational Units/$OU"

# Update the GPO
Update-ADGroupPolicy -Identity $GPO
```

- https://galaxy.ansible.com/ui/repo/published/check_point/mgmt/content/module/cp_mgmt_add_outbound_inspection_certificate/
- https://galaxy.ansible.com/ui/repo/published/check_point/mgmt/content/module/cp_mgmt_outbound_inspection_certificate_facts/
- https://galaxy.ansible.com/ui/repo/published/check_point/mgmt/content/module/cp_mgmt_https_layer/
- https://galaxy.ansible.com/ui/repo/published/check_point/mgmt/content/module/cp_mgmt_https_section/
- https://galaxy.ansible.com/ui/repo/published/check_point/mgmt/content/module/cp_mgmt_https_rule/
- Create certificate on firewall
  - define a varialble with the base 64 encoded password
    - b64string: "{{ password | b64encode }}"
- Export the certificate from firewall
- Create Group Policy Object (GPO) on DC-1
  - Open Group Policy Management Console (GPMC)
  - Right-click on a domain or organizational unit (OU) where you want to apply the policy.
  - Select "Create a GPO Here" and give it a meaningful name (e.g., "Import Firewall Certificate").
  - Link the GPO to the desired domain or OU.
- Edit the GPO
  - Right-click on the created GPO and select "Edit"
- Navigate to Computer Configuration:
  - In the Group Policy Management Editor, navigate to "Computer Configuration"
- Go to Policies -> Windows Settings -> Security Settings
  - Expand "Security Settings"
- Locate Certificate Policies
  - Under "Security Settings", expand "Public Key Policies".
  - Right-click on "Certificate Policies" and select "Import".
- Import the Certificate
  - In the "Import Certificate" wizard:
    - Browse to the location of your firewall certificate (.cer file).
    - Ensure the "Place certificate in the following store" is selected.
    - Choose "Local Machine".
    - Choose "Trusted Root Certification Authorities".
    - Click "Next" and follow the remaining prompts to complete the import.
- Configure the GPO to Import the Certificate:
  - In the Group Policy Management Editor, navigate to "Computer Configuration" -> "Policies" -> "Windows Settings" -> "Security Settings" -> "Public Key Policies".
  - Right-click on the imported certificate policy and select "Properties".
  - In the "Security" tab, add the "Authenticated Users" group and give it the "Read" permission.
  - Click "Apply" and "OK".
- Link the GPO
  - Ensure that the GPO is linked to the desired domain or OU.

```
# Replace placeholders with your actual values
$gpoName = "Import Firewall Certificate"
$certPath = "C:\path\to\your\certificate.cer"
$ouPath = "OU=YourOU,DC=yourdomain,DC=com"

# Create the GPO
New-ADGroupPolicyObject -Name $gpoName -Path $ouPath

# Import the certificate
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($certPath)
$cert.Install()

# Get the GPO's GUID
$gpoGuid = (Get-ADGroupPolicyObject -Identity $gpoName).GUID

# Set the GPO's permissions
Set-ADGroupPolicyObjectPermission -Identity $gpoGuid -Principal "Authenticated Users" -PermissionRead -AccessAllowed

# Link the GPO to the OU
Add-ADGroupPolicyObjectLink -Identity $ouPath -GroupPolicyObject $gpoGuid
```

script explanation:
- Replace Placeholders: Replace the placeholders with your actual GPO name, certificate path, and OU path.
- Create GPO: New-ADGroupPolicyObject creates a new GPO in the specified OU.
- Import Certificate: New-Object creates a new X509Certificate2 object, Import imports the certificate, and Install installs it into the Local Machine's Trusted Root Certification Authorities store.
- Get GPO GUID: Get-ADGroupPolicyObject retrieves the GPO's GUID, which is needed for further operations.
- Set Permissions: Set-ADGroupPolicyObjectPermission grants "Read" permission to the "Authenticated Users" group for the GPO.
- Link GPO: Add-ADGroupPolicyObjectLink links the GPO to the specified OU.
- OU=Corp for our lab

# Configure Branch 2
🌱 this needs to be developed- Initial settings
- FTW
- Gaia config
- Create cluster
- policy
- VPN tunnel bring up
- DHCP helper?????

# Configure Branch 3
🌱 this needs to be developed
- Initial settings
- FTW
- Gaia config
- Create cluster
- policy
- VPN tunnel bring up
- DHCP helper?????

# Demonstration
🌱 this needs to be developed
- branches 2 and 3
  - access to file server
  - access to DMZ web servers
  - internet access goes out local firewalsl
  - support team can access and support
- secured access to Internet, blocking prohibited access
- examine peer-to-peer access between branches
- DHCP across branches
- identity awareness for access
