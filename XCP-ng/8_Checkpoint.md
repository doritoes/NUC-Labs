# Install Check Point Firewall
The Check Point security gateway is a fully-featured firewall. For testing purposes, a virtual firewall running an evaluation license is a great place to engineer and validate architectures and designs.

I strongly recommend reading the book **Check Point Firewall Administration R81.10+**. The author uses Oracle VirtualBox to build a lab environment. You can adapt the lab to run on XCP-ng.
- https://github.com/PacktPublishing/Check-Point-Firewall-Administration-R81.10-

This section will walk you through setting up a simple Check Point firewall environment on XCP-ng. From this, you can expand on the concept to run more complex designs.

IMPORTANT NOTES
- Be sure to disable TX checksumming on the network interfaces connected to the firewall as noted below
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

- Download Check Point R81.20 Gaia Fresh Install iso
  - https://support.checkpoint.com/results/download/124397
- Download the R81.20 SmartConsole package
  - https://sc1.checkpoint.com/documents/Jumbo_HFA/R81.20_SC/R81.20/R81.20_Downloads.htm
  - Check Point has begun blocking SmartConsole client downloads if you don't have
    - an account
    - a "software subscription" to download the file (my private account has CCSE and CCSM but it can't download the client any more
  - We will cover the workarounds
    - Use the link from within the SMS Web GUI
    - Use the web version of SmartConsole

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
  - Template: **win10-lan-ready**
  - Name: **checkpoint-console**
  - Description: **R81.20 Check Point SmartConsole**
  - First Interface:
    - Network: from the dropdown select the **Pool-wide network associated with eth0**
    - This will allow us to download files and packages all allow setting up the Check Point management network
    - We will disable this interface later
  - Second Interface:
    - Click **Add Interface**
    - Network: from the dropdown select the **Check Point Management**
    - This is the management network for the Check Point appliances
  - Click **Create**
- The details for the new Check Point VM are now displayed
- Click the **Console** tab
- Change the IP address of the second interface to a static IP 192.168.103.100/24
  - Start > Settings > Network & internet
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
    - A standalone gateway might run ok with 2 cores in some cases
  - RAM: **4GB**
    - SMS reqires more; we will increase this later
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
- Select a password for the "admin" account
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
  - `./install -d rhel -m el7`

## Halt the system
- `halt`

## Convert to Template
- Click the **Advanced** tab
- Click **Convert to template**

# Create Check Point Management Server (SMS)
Steps:
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **checkpoint-template**
  - Name: **checkpoint-sms**
  - Description: **R81.20 Check Point SMS**
  - CPU: **4 vCPU**
  - RAM: **6GB** minimum in a Lab; do 8GB if you can
  - Interfaces: Remove all interfaces except Check Point Management
  - Click **Create**
- Log in the console
- Configure hostname and IP address
  - `set hostname SMS`
  - `set interface eth0 ipv4-address 192.168.103.4 mask-length 24`
  - `set interface eth0 comments "Management"`
  - `set interface eth0 state on`
  - `save config`

# Create Firewalls
Steps:
- Create Gateway 1 (GW1)
  - From the left menu click **New** > **VM**
    - Select the pool **xcgp-ng-lab1**
    - Template: **checkpoint-template**
    - Name: **checkpoint-gw1**
    - Description: **R81.20 Check Point Gateway 1**
    - CPU: **4 vCPU**
    - RAM: **4GB**
    - Click **Create**
  - Disable TX Checksumming
    - Click the Network tab
    - Each interface has a blue gear icon to the right
    - For each interface, click the blue gear, click to disable TX checksumming, and click OK
  - Log in the console
  - Configure hostname and IP address
    - `set hostname GW1`
    - `set interface eth3 ipv4-address 192.168.103.2 mask-length 24`
    - `set interface eth3 comments "Management"`
    - `set interface eth3 state on`
    - `save config`
  - You can now ping the SMS: `ping 192.168.103.4`
- Create Gateway 2 (GW2)
  - From the left menu click **New** > **VM**
    - Select the pool **xcgp-ng-lab1**
    - Template: **checkpoint-template**
    - Name: **checkpoint-gw2**
    - Description: **R81.20 Check Point Gateway 2**
    - CPU: **4 vCPU**
    - RAM: **4GB**
    - Click **Create**
  - Disable TX Checksumming
    - Click the Network tab
    - Each interface has a blue gear icon to the right
    - For each interface, click the blue gear, click to disable TX checksumming, and click OK
  - Log in the console
  - Configure hostname and IP address
    - `set hostname GW2`
    - `set interface eth3 ipv4-address 192.168.103.3 mask-length 24`
    - `set interface eth3 comments "Management"`
    - `set interface eth3 state on`
    - `save config`
  - You can now ping the SMS: `ping 192.168.103.4`

# Set up SMS
- On the Windows workstation, point browser to https://192.168.103.4
- Log in as `admin` and the password you selected
- Complete First Time Configuration Wizard (FTCW)
  - Continue with R81.20 configuration
  - Accept the Managment connection configuration
    - Add Default gateway **192.168.103.1**
  - Host Name: **SMS**
  - Domain Name: **xcpng.lab**
  - Primary DNS Server: 9.9.9.9 (for now; set to your internal DNS service later)
  - Secondary DNS Server: 1.1.1.1
  - Select Use Network Time Protocol (NTP) and select a time zone
  - Select **Security Gateway and/or Security Management**
  - Leave **Security Management** selected
  - <ins>Uncheck</ins> Security Gateway
  - Leave Security Management set to **Primary**
  - Select **Define a new administrator**
    - Administrator: **cpadmin**
    - Password: *select a password*
  - Leave **Any IP Address** can log in for now
    - Will secure to the internal network or perhaps specific administrator IP addresses later
  - Click **Finish**
  - Wait patiently as the configuration is applied
  - When Configuration completed successfully is displayed, click **OK**
- You are now logged in to the Web GUI
- Next to *Manage Software Blades using SmartConsole* click **Download Now**

# Connect to the SMS
- Install the SmartConsole you downloaded from the Web GUI on the Windows 10 workstation
  - Check the box and click **Install**
- Login
  - Username: **cpadmin**
  - Password: *the password you selected*
  - Server Name or IP Address: **192.168.103.4**
  - Accept the server fingerprint
  - SmartConsole will update itself; click **Relaunch Now**

NOTE The SMS takes some time to start all the management processes after a reboot
- Check on SMS: `api status`

Alternate method: https://support.checkpoint.com/results/sk/sk170314
- Point your browser to https://192.168.103.4/smartconsole
- This is the web version of SmartConsole
- In our Lab testing, Web SmartConsole did not work at this point
  - Once the management server can get to the Internet it can update and install Web SmartConsole
  - Web SmartConsole apparently runs in a Docker container

# Set up Firewalls
## GW1
- On the Windows workstation, point browser to https://192.168.103.2
- Complete First Time Configuration Wizard (FTCW)
  - Continue with R81.20 configuration
  - Accept the Management Connection configuration (eth3)
    - Leave Default gateway blank
  - Configure Internet connection
    - Set interface to **eth0**
    - Configure IPv4: **Manually**
      - IPv4 address: *Select an IP address from your Lab network*
      - Subnet mask: *Use the same mask as your Lab network*
      - NOTE It is not recommended to use DHCP on the external interface
          - Before considering this, read up on [Dynamically Assigned IP Address (DAIP)](https://support.checkpoint.com/results/sk/sk167473)
  - Host Name: GW1
  - Domain Name: xcpng.lab
  - Primary DNS Server: 9.9.9.9 (for now; set to your internal DNS service later)
  - Secondary DNS Server: 1.1.1.1
  - Select Use Network Time Protocol (NTP) and select a time zone
  - Select **Security Gateway and/or Security Management**
  - Leave Security Gateway selected
  - <ins>Uncheck</ins> Security Management
  - Leave Security Management set to Primary
  - Select **Unit is part of a cluster** and leave type as **ClusterXL**
  - Enter an Activation key
    - `xcplab123!`
  - Click Finish and Yes to start the process
  - Acccept the Reboot
  - Log back in
  - Configure interfaces
    - From the left menu click Network Management > **Network Interfaces**
    - Edit **eth1**
      - Enable: **Checked**
      - Comment: **Inside**
      - IPv4: Select **Use the following IPv4 address**
        - IPv4 address: **10.1.1.2**
        - Subnet mask: **255.255.255.0**
      - Click **OK**
    - Edit **eth2**
      - Enable: **Checked**
      - Comment: **DMZ**
      - IPv4: Select **Use the following IPv4 address**
        - IPv4 address: **192.168.102.2**
        - Subnet mask: **255.255.255.0**
      - Click **OK**
    - Edit **eth4**
      - Enable: **Checked**
      - Comment: **Sync**
      - IPv4: Select **Use the following IPv4 address**
        - IPv4 address: **192.168.104.2**
        - Subnet mask: **255.255.255.0**
      - Click **OK**
  - Edit the Default Route
    - From the left menu click Network Management > **IPv4 Satatic Routes**
    - Click **Add Gateway** > **IP Address**
    - Enter the default gateway for your Lab network
    - Click **OK**

## GW2
- On the Windows workstation, point browser to https://192.168.103.3
- Complete First Time Configuration Wizard (FTCW)
  - Continue with R81.20 configuration
  - Accept the eth3 configuration (Management)
    - Leave Default gateway blank
  - Configure Internet connection
    - Set interface to **eth0**
    - Configure IPv4: **Manually**
      - IPv4 address: *Select an IP address from your Lab network*
      - Subnet mask: *Use the same mask as your Lab network*
      - NOTE It is not recommended to use DHCP on the external interface
          - Before considering this, read up on [Dynamically Assigned IP Address (DAIP)](https://support.checkpoint.com/results/sk/sk167473)
  - Host Name: GW2
  - Domain Name: xcpng.lab
  - Primary DNS Server: 9.9.9.9 (for now; set to your internal DNS service later)
  - Secondary DNS Server: 1.1.1.1
  - Select Use Network Time Protocol (NTP) and select a time zone
  - Select **Security Gateway and/or Security Management**
  - Leave Security Gateway selected
  - <ins>Uncheck</ins> Security Management
  - Leave Security Management set to Primary
  - Select **Unit is part of a cluster** and leave type as **ClusterXL**
  - Enter an Activation key
    - `xcplab123!`
  - Click Finish and Yes to start the process
  - Acccept the Reboot
  - Log back in
   - From the left menu click Network Management: **Network Interfaces**
    - Edit **eth1**
      - Enable: **Checked**
      - Comment: **Inside**
      - IPv4: Select **Use the following IPv4 address**
        - IPv4 address: **10.1.1.3**
        - Subnet mask: **255.255.255.0**
      - Click **OK**
    - Edit **eth2**
      - Enable: **Checked**
      - Comment: **DMZ**
      - IPv4: Select **Use the following IPv4 address**
        - IPv4 address: **192.168.102.3**
        - Subnet mask: **255.255.255.0**
      - Click **OK**
    - Edit **eth4**
      - Enable: **Checked**
      - Comment: **Sync**
      - IPv4: Select **Use the following IPv4 address**
        - IPv4 address: **192.168.104.3**
        - Subnet mask: **255.255.255.0**
      - Click **OK**
  - Edit the Default Route
    - From the left menu click Network Management > **IPv4 Satatic Routes**
    - Click **Add Gateway** > **IP Address**
    - Enter the default gateway for your Lab network
    - Click **OK**

# Create Firewall Cluster
## Testing Connectivity
- From the Windows workstation try to ping the firewalls (from command line)
  - `ping 192.168.103.2`
  - `ping 192.168.103.3`
- Now try to connect to TCP port 18191 (required for communication) using powershell
  - `tnc -p 18191 192.168.103.2`
  - `tnc -p 18191 192.168.103.3`
- Try to ping the SMS
  - `ping 192.168.103.4`
- If you want to ping the Windows 10 machine you will need to allow ping in the Windows Firewall
- Note that you can't ping the firewall gateways. If you run the command `fw unload local`, they become pingable because the firewall policy "InitialPolicy" is removed.

## Create Cluster Object
- On the Windows workstation, Log in to SmartConsole again
- From the left menu, click **Gateways & Servers** (the default view when using SmartConsole for the first time)
- The **New*** icon doesn't appear on smaller screens, click the "..." icon next to the Search bar to review more actions
- Click **New**  > **Cluster** > **Cluster**
- Click **Wizard Mode**
  - Cluster Name: **Gateway_Cluster**
  - Cluster IPv4 Address: *select an IP address from your Lab network* (the external cluster IP and the "real" external IP addresses of the cluster members are all on the same subnet)
  - Leave cluster settings at the default (ClusterXL and High Availability)
  - Click **Add** > **New Cluster Member** to add the first firewall, GW1
    - Name: **GW1**
    - IPv4 Address: **192.168.103.2** (the management IP)
    - Activation Key: `xcplab123!` and confirm it
    - Click **Initialize**
    - Click **OK**
  - Click **Add** > **New Cluster Member** to add the second firewall, GW2
    - Name: **GW1**
    - IPv4 Address: **192.168.103.2** (the management IP)
    - Activation Key: `xcplab123!` and confirm it
    - Click **Initialize**
    - Click **OK**
  - Configure Cluster Topology
    - 192.168.104.0/255.255.255.0 = Cluster Synchronization Primary
    - 192.168.103.0/255.255.255.0 = Representing a cluster interface **192.168.103.1** **255.255.255.0**
      - management interfaces can be a cluster or non-monitored private interfaces; for this Lab setup a clustered interace is used
    - 192.168.102.0/255.255.255.0 = Representing a cluster interface **192.168.102.1** **255.255.255.0**
    - 10.1.1.0/255.255.255.0 = Representing a cluster interface **10.1.1.1** **255.255.255.0**
    - Your Lab network = Representing a cluster interface withe cluster IP address you selected and your Lab's subnet mask
    - Click Finish
- Double-Click the new **Gateway_Cluster** you created
  - From the tree on the left, click **Network Management**
  - Click **Get Interfaces** > **Get Interfaces Without Topology**
  - Edit eth0
    - Under Topology click Modify
    - Leads To: **Override** > **Internet**
    - Security Zone: **According to topology: ExternalZone**
    - Click **OK** and **OK**
  - Edit eth1
   - Under Topology click Modify
    - Security Zone: **According to topology: InternalZone**
    - Click **OK** and **OK**
  - Edit eth2
    - Under Topology click Modify
    - Leads To: **Override** > **This Network (Internal)** **Network defined by the interface IP and Net Mask**
    - Check **Interface leads to DMS**
    - Security Zone: **According to topology: DMZZone**
    - Click **OK** and **OK**
  - Edit eth3
   - Under Topology click Modify
    - Security Zone: **According to topology: InternalZone**
    - Click **OK** and **OK**
  - Edit eth4
   - Under Topology click Modify
    - Security Zone: **According to topology: InternalZone**
    - Click **OK** and **OK**
- Re-open **Gateway_Cluster**
- General Properites
  - Uncheck IPSec VPN for this lab (feel free to leave it on a experiment)
  - Check Monitoring
  - Optionally Check Application Control and URL Filtering if you would like to experiment 
- NAT
  - Check Hide internal networks behind the Gateway's external IP
    - This is acceptable for this Lab and cases where there are less that 50 hosts behind the firewall
  - Click **OK**
- Network Managment
  - To calculate the network topology from routes
    - Click Get Interfaces > Get Interfaces With Topology
- Click **Publish**

# Create Network and Host Objects
- On the Windows VM log in to Smart Console
- From the menu on the left, click **Command Line**
- Paste in the following text
~~~
add host name "SmartConsole" ip-address "192.168.103.100"
add host name "DNS_1.1.1.1" ip-address "1.1.1.1"
add host name "DNS_9.9.9.9" ip-address "9.9.9.9"
add host name "workstation1" ip-address "10.1.1.100"
add host name "dmzserver" ip-address "192.168.103.10"
add network name "Inside_Network" subnet "10.1.1.0" subnet-mask "255.255.255.0" color "Blue"
add network name "DMZ_Network" subnet "192.168.102.0" subnet-mask "255.255.255.0" color "Red"
add network name "Mgmt_Network" subnet "192.168.103.0" subnet-mask "255.255.255.0"
~~~

# Create Initial Policy
This policy is overy permissive, but it's a place to start.

- Click the Check Point menu button at top left then click **Manage Polices and Layers**
- Click the New icon under Policies
  - Name: **AccessPolicy**
  - Click **OK**
  - Click **Close**
- From the left menu click **Security Policies**
- If not already selected, click on the policy **AccessPolicy** or click on "+" and open it
- Add first rule (at top) - Managment
  - Name: Management rule
  - Source: SmartConsole (192.168.103.100)
  - Destinations: GW1 and GW2
  - Services: https and ssh_version_2
  - Action: Accept
  - Track: Log
- Add second rule - Stealth
  - Name: Stealth rule
  - Source: *Any
  - Destinations: GW1 and GW2
  - Services: *Any
  - Action: Drop
  - Track: Log
- Add third rule - Outbound Web Traffic
  - Name: Outbound Web Traffic
  - Source: Inside_Network
  - Destinations: ExternalZone
  - Services: http and https
  - Action: Accept
  - Track: Log
- Add fourth rule - Inside to DMZ
  - Name: Outbound Web Traffic
  - Source: InternalZone
  - Destinations: DMZZone
  - Services: http and https
  - Action: Accept
  - Track: Log
- Add fifth rule - Internal Zone to External DNS
  - Name: Internal Zone to External DNS
  - Source: InternalZone
  - Destinations: ExternalZone
  - Services: dns (service group)
  - Action: Accept
  - Track: Log
- Add sixth rule - Internal Zone to External NTP
  - Name: Internal Zone to External NTP
  - Source: InternalZone
  - Destinations: ExternalZone
  - Services: ntp (service group)
  - Action: Accept
  - Track: Log
- Modify the last "Cleanup rule" Track from None to Log
- Click **Publish**
- Click **Install Policy** and install **AccessPolicy**

# Basic Testing
- From the left menu click **Logs & Monitor**
- From the ribbon, click **Logs**
- From the Windows VM, open a public web page such as https://ipchicken.com
- Note that the management network is in the "InternalZone"

# Add Windows 10 Workstation
- New > VM
- Pool **xcp-ng-lab1**
- Template: **win10-lan-ready**
- Name: **workstation1**
- Description: **Windows 10 on Check Point Inside network**
- Interfaces: Change to **Check Point Inside***
- Click **Create**
- Log in
- Set Static IP address
  - Use the following IP address
    - IP address: 10.1.1.100
    - Subnet mask: 255.255.255.0
    - Default gateway: 10.1.1.1
  - Use the following DNS server addresses:
    - Preferred DNS server: 9.9.9.9
    - Alternate DNS server: 1.1.1.1
  - Do you want to allow your PC to be discoverable by other PCs and devices on this network? **Yes**
- Test access
  - Access to the internet should work
  - Access to the Web GUI of the firewall servers will not work
    - https://192.168.103.2
    - https://192.168.103.3
    - https://192.168.103.4
  - Review the logs to confirm
- Add a firewall rule to allow InsideZone to Inside zone for https and ssh
  - Try web access to https://192.168.103.4
  - Try ssh access
    - cmd or powershell: `ssh admin@192.168.103.4`
    - Accept the fingerprint: **Yes**
    - Enter the password you selected
  - Note that the Stealth rule prevents access (or is meant to protect access) to 192.168.103.2 and 192.168.103.3
    - What is the "best" way to give 10.1.1.100 https and ssh access to GW1 and GW2?
    - First try accessing it. It works! Can you find this traffic in the logs? from 10.1.1.100 to 192.168.103.2 and .3 on https?
    - Click **Action** > **Implied Rules**
    - Under **Configuration**, click **Log Implied Rules**
    - **Publish** and **Push Policy**
    - This is safe to enable in our Lab; don't roll this to production
    - Retest testing access, the search for `"Implied Rule"` (with the double quotes) in the Logs
      - Does this make you re-think any of the rule sin the policy?
    - How does setting Check Point to allow Any host to manage SmartConsole affect the security of the system here?
- Note that if you install SmartConsole on this system, you will need to open [some more ports](https://support.checkpoint.com/results/sk/sk52421) to the SMS
  - FW1_mgmt (TCP/258)
  - CPMI (TCP/18190)
  - CP_reporting (TCP/18205)
  - FW1_ica_mgmt_tools (TCP/18265)
  - CPM (TCP/19009)

# Add DMZ Server
- New > VM
- Pool **xcp-ng-lab1**
- Template: **ubuntu-server-lan**
- Name: **dmzserver**
- Description: **Ubuntu web server in DMZ**
- Interfaces: Change to **Check Point DMZ***
- Click **Create**
- Log in
- Set Static IP address
  - https://www.linuxtechi.com/static-ip-address-on-ubuntu-server/
  - `sudo vi /etc/netplan/00-installer-config.yaml`
~~~
# This is the network config written by 'subiquity'
network:
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 192.168.102.10/24
      nameservers:
        addresses: [9.9.9.9, 1.1.1.1]
      routes:
        - to: default
          via: 192.168.102.1
  version: 2
~~~
  - `sudo netplan apply`
- You will need to allow the DMZ server to get to the internet to install Apache
  - Add a rule to allow 192.168.102.10 to *Any for services https, https, dns, and icmp-requests
  - Publish and Install Policy
- Install web server
  - `sudo apt update && sudo apt install apache2`
  - `sudo ufw default allow outgoing`
  - `sudo ufw default deny incoming`
  - `sudo ufw allow Apache`
  - `sudo ufw allow OpenSSH`
  - `sudo ufw show added`
  - `sudo ufw status`
  - `sudo ufw enable`
  - `sudo ufw status`
- From the Windows 10 workstation with IP 10.1.1.100
  - http://192.168.102.10
- From the command line
  - `ssh lab@192.168.102.10`
  - this will fail
  - add a firewall rule to allow ssh access to the dmzserver

# Exposing the DMZ server to the Lab
Since the Lab network is our simulated Internet, we are going to use another IP address from the Lab network to access the DMZ web server.

- Select an IP address from your Lab network on the same subnet as the "public" external IPs on the firewall
- Create a new firewall rule
  - Soure: ExternalZone
  - Destination: dmzserver (192.168.102.10)
  - Services: http
- Modify the `dmzserver` object
  - Click NAT
  - Check Add automated address translation rules
  - Translation method: Static
  - Translate to IP address:
    - IPv4 address: the IP address you assigned in your Lab
- Publish and push policy
- From workstation1 (10.1.1.100)
  - http://192.168.102.10
  - `http://<the IP address you assigned>`
- From a device in your Lab
  - `http://<the IP address you assigned>`
- Review the logs to see what rule was matched for each connection
  - Do you see any drops? What could be the cause of out-of-state drops?

# Advanced Notes
Lab users not familiar with Check Point may wonder about these

- Does the Check Point management interface provide management/data plan separation?
  - Not by default. Management Data Plane Separation (MDPS) must be enabled and has requirements - https://support.checkpoint.com/results/sk/sk138672
- Does Check Point offer application control and URL filtering?
  - Yes

# Ideas for Advanced Labs
- Create Windows domain and workstations, and use Identity collector to control access by identity
- Put a VyOS router in front to simulate the ISP, and add another security gateway so you can test VPN
