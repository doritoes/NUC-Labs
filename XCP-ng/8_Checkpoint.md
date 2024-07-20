# Install Check Point Firewall
The Check Point security gateway is a fully-featured firewall. For testing purposes, a virtual firewall running an evaluation license is a great place to engineer and validate architectures and designs.

I strongly recommend reading the book **Check Point Firewall Administration R81.10+**. The author uses Oracle VirtualBox to build a lab environment.
- https://github.com/PacktPublishing/Check-Point-Firewall-Administration-R81.10-

This section will walk you thorugh setting up a simple Check Point firewall environment on XCP-ng. From this, you can expand on the concept to run more complex designs.

IMPORTANT NOTES
- Be sure to disable TX checksumming on the network interfaces connected to the firewall as noted below.
- Getting Check Point images
- Trials and Evaluations
  - 15 day trial
  - 30 evaluation license

# Configure Networking
- Log in to Xen Orchestra (XO)
- Configure networks
  - From the left menu click **Home** > **Hosts**
  - Click on the host you configured (i.e., **xcp-ng-lab1**)
  - Click the **Network** tab
  - Firewall "Inside" interface
    - Under Private networks click **Manage**
      - Click **Add a Network**
        - Interface: **eth0**
        - Name: **Check Point Inside**
        - Description: **Check Point Inside**
        - MTU: *leave blank* (default 1500)
        - VLAN: **300**
        - NBD: **No NBD Connection** (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
        - Click **Create network**
      - Renavigate to **Home** > **Hosts** > **xcp-ng-lab1** > **Network**
      - Under the list of PIFs (physical interfaces), find the new Check Point Inside interface, click **Status** to  disconnect it from your the eth0 interface
  - Firewall "DMZ" interface
    - Under Private networks click **Manage**
      - Click **Add a Network**
        - Interface: **eth0**
        - Name: **Check Point DMZ**
        - Description: **Check Point DMZ**
        - MTU: *leave blank* (default 1500)
        - VLAN: **400**
        - NBD: **No NBD Connection** (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
        - Click **Create network**
      - Renavigate to **Home** > **Hosts** > **xcp-ng-lab1** > **Network**
      - Under the list of PIFs (physical interfaces), find the new Check Point DMZ interface, click **Status** to  disconnect it from your the eth0 interface
  - Firewall "Management" interface
    - Under Private networks click **Manage**
      - Click **Add a Network**
        - Interface: **eth0**
        - Name: **Check Point Management**
        - Description: **Check Point Management**
        - MTU: *leave blank* (default 1500)
        - VLAN: **500**
        - NBD: **No NBD Connection** (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
        - Click **Create network**
      - Renavigate to **Home** > **Hosts** > **xcp-ng-lab1** > **Network**
      - Under the list of PIFs (physical interfaces), find the new Check Point Management interface, click **Status** to  disconnect it from your the eth0 interface
  - Firewall "Sync" interface
    - Under Private networks click **Manage**
      - Click **Add a Network**
        - Interface: **eth0**
        - Name: **Check Point Sync**
        - Description: **Check Point Sync**
        - MTU: *leave blank* (default 1500)
        - VLAN: **600**
        - NBD: **No NBD Connection** (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
        - Click **Create network**
      - Renavigate to **Home** > **Hosts** > **xcp-ng-lab1** > **Network**
      - Under the list of PIFs (physical interfaces), find the new Check Point Sync interface, click **Status** to  disconnect it from your the eth0 interface

# Download the ISO and SmartConsole Client
For this lab we are using [R81.20](https://support.checkpoint.com/results/sk/sk173903)

- Download Check Point R81.20 Gaia Fhesh Install iso
  - https://support.checkpoint.com/results/download/124397
- Download the R81.20 SmartConsole package
  - https://sc1.checkpoint.com/documents/Jumbo_HFA/R81.20_SC/R81.20/R81.20_Downloads.htm
  - Check Point has begun blocking SmartConsole client downloas if you don't have
    - an account
    - a "software subscription" to download the file (my private account has CCSE and CCSM but it can't download the client any more
  - We will cover the workarounds using the WebConsole

# Upload the ISO
If you linked storage to a file share, copy the file there.

Or, if you created local storage, upload the ISO there.
- From the left menu Click Import > Disk
- Select the SR from the dropdown, LOCAL-ISO
- Drag and drop the vyos ISO file in the box
- Click Import

# Create Windows Workstation
This Windows 10 workstation will be used to build  the environment and later manage it.

- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **win10-lab-ready**
  - Name: **checkpoint-console**
  - Description: **R81.20 Check Point SmartConsole**
  - First Interface:
    - Network: from the dropdown select the **Pool-wide network associated with eth0**
    - This will allow us to download files and packages all allow setting up the Check Point managment network
    - We will move the Windows workstation to the Check Point Inside network later
  - Second Interface:
    - Click **Add Interface**
    - Network: from the dropdown select the **Check Point Management**
    - This is the managment network for the Check Point appliances
  - Click **Create**
- The details for the new Check Point VM are now displayed
- Click the **Console** tab
- Change the IP address of the second interface to a static IP 192.168.103.100/24
  - Start > Settings > Newtork & internet
  - From the left menu click Ethernet
  - Click Change adapter options
  - Right-click Ethernet 2 and click Properties
  - Click Internet Protocol Version 4 (TCP/IPv4) and then click Properties
  - Select **Use the following IP address**
    - IP address: 192.168.103.100
    - Subnet mask: 255.255.255.0
    - Gateway: blank
    - Preferred DNS: blank
    - Alternate DNS: blank
    - Click OK and then click Close
- Download and install Winscp: https://winscp.net/eng/download.php
  - Typical installation with default settings suites our purposes
- Download Guest tools for Linux
  - Download from https://www.xenserver.com/downloads
  - XenServer VM Tools for Linux > Download XenServer VM Tools for Linux

# Create Check Point Template
Comments on sizing (vCPU, RAM, storage):
- https://sc1.checkpoint.com/documents/R81.20/WebAdminGuides/EN/CP_R81.20_RN/Content/Topics-RN/Open-Server-Hardware-Requirements.htm

Steps:
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **checkpoint-template**
  - Description: **R81.20 Check Point Template**
  - CPU: **4 vCPU**
    - Will increase to 6 or 8 for the SMS (managment server) later
    - A standalone gateway might run ok with 2 cores in some cases
  - RAM: **4GB**
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the Check Point Gaia ISO image you uploaded*
  - First Interface:
    - Network: from the dropdown select the **pool-wide network associated with eth0**
    - This is the "Internet" for the Lab
  - Second Interface: Click **Add interface**
    - Network: from the dropdown select the **Check Point Inside** network you created earlier
  - Third Interface: Click **Add interface**
    - Network: from the dropdown select the **Check Point DMZ** network you created earlier
  - Fourth Interface: Click **Add interface**
    - Network: from the dropdown select the **Check Point Management** network you created earlier
  - Fifth Interface: Click **Add interface**
    - Network: from the dropdown select the **Check Point Sync** network you created earlier
  - Disks: Click **Add disk**
    - Add **128GB** disk
  - Click **Create**
- The details for the new Check Point VM are now displayed
- Click the **Network** tab
  - Next to each interface is a small settings icon with a blue background
  - For every interface click the gear icon then <ins>disable TX checksumming</ins>
- Click **Console** tab and watch as the system boots

# Base Configuration
## Boot from ISO
- At the boot menu, select **Install Gaia on this system**
- Accept the installation message **OK**
- Confirm the keyboard type
- Accept the default partitions sizing for 128GB drive
  - Swap: 7GB (6%)
  - Root: 20GB (16%)
  - Logs: 20GB (16%)
  - Backup and upgrade: 79GB (62%)
  - Feel free to customize
  - Choose **OK**
- Select a passsword for the "admin" account
- Select a password for <ins>maintenance mode "admin" user</ins>
- Select **eth3** as the management port
  - IP address: **192.168.103.254"
  - Netmask: **255.255.255.0**
  - Default gateway: **blank**
    - *will auto populate with 192.168.103.254, clear it*
  - NO DHCP server on the management interface
- Confirm you want to continue with formatting the drive **OK**
- When the message `Installation complete.` message appears
  - Press enter
  - Wait for the system to start to reboot, then eject the ISO

## Set the Hostname
- Log in from the Console
- `set hostname CPTEMPLATE`
- `save config`

## Install Guest Tools
- Set the user shell to bash
  - `set expert-password`
    - select a password for "expert mode"
  - `expert`
    - enter the password when prompted
  - `chsh -s /bin/bash admin`
- From the Windows machine point WinSCP to the device:
  - 192.168.103.254
  - Username: admin
  - Password: the password you selected
  - Accept the warnings
  - Drag LinuxGuestTools-8.4.0-1.tar.gz file to the Check Point device's `/home/admin` folder
  - Close WinSCO
- Revert to clish shell
  - `chsh -s /etc/cli.sh admin`
- Install guest tools
  - `tar xzvf LinuxGuestTools-8.4.0-1.tar.gz`
  - `cd LinuxGuestTools-8.4.0-1`
  - ./install -d rhel -m el7`

## Halt the system
- `halt`

## Convert to Template
- Click the **Advanced** tab
- Click **Convert to template**

# Create Check Point Management Server (SMS)

# Configure SMS

# Create Firewalls

# Create Cluster

# Create Initial Policy

# Add DMZ Server

# Testing

# Ideas for Advanced Labs
- Create Windows domain and workstations, and use Identity collector to control access by identity
- Put a VyOS router in front to simulate the ISP, and add another security gateway so you can test VPN
