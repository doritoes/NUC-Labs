# Install Check Point Firewall
The Check Point security gateway is a fully-featured firewall. For testing purposes, a virtual firewall running an evaluation license is a great place to engineer and validate architectures and designs.

I strongly recommend reading the book **Check Point Firewall Administration R81.10+**. The author uses Oracle VirtualBox to build a lab environment. You can adapt the lab to run on XCP-ng.
- https://github.com/PacktPublishing/Check-Point-Firewall-Administration-R81.10-

This section will walk you through setting up a "simple" ElasticXL Check Point firewall environment on XCP-ng. From this, you can expand on the concept to run more complex designs.

IMPORTANT NOTES
- This Lab uses R82 with the new <i>cluster method ElasticXL</i>. This is VERY DIFFERENT from the traditional ClusterXL method.
- ElasticXL is <i>only</i> supported on <i>physical appliances</i> with R82 as of the time of this writing; this Lab testing is obviously not for production
  - https://sc1.checkpoint.com/documents/R82/WebAdminGuides/EN/CP_R82_ScalablePlatforms_AdminGuide/Content/Topics-SPG/ElasticXL/ElasticXL-Important-Notes.htm
  - https://community.checkpoint.com/t5/Security-Gateways/R82-elasticXL-lab/td-p/219343
  - ElasticXL Cluster requires at least 4 interfaces on each ElasticXL Cluster Member:
    - A dedicated management interface (the port "Mgmt" is selected automatically) (eth0)
    - A dedicated sync interface (the port "Sync" is selected automatically) (eth1)
    - Only one ElasticXL Cluster is supported in the same Layer 2 broadcast domain (connecting Sync interfaces of different ElasticXL Clusters is not supported)
    - Configuring the Sync interface as VLAN Trunk is not supported (it's UDP broadcast)
    - ElasticXL Cluster sends all traffic over the Sync network in clear-text (non-encrypted)
    - ElasticXL Cluster automatically configures the IP address of the sync network to 192.0.2.0/24. If needed, later it is possible to change the IP address of the sync network.
    - Up two 3 members per site, maximum 2 sites (total 6 members)
- Be sure to disable TX checksumming on the network interfaces connected to the firewall as noted below
- With ElasticXL the FTW should run only on first member (AKA SMO); the rest of the members are installed without any additional steps on them.
- Getting Check Point images may require creating an account on Check Point's web site
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
  - Firewall "Sync" interface
    - Under Private networks click **Manage**
      - Click **Add a Network**
        - Interface: *none* (this creates a Private network)
        - Name: **Check Point Sync**
        - Description: **Check Point Sync**
        - MTU: *leave blank* (default 1500)
        - VLAN: *Leave blank because the Sync interface is not supposed to be on a VLAN*
        - NBD: **No NBD Connection** (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
        - Click **Create network**

# Download the ISO and SmartConsole Client
For this lab we are using [R820](https://support.checkpoint.com/results/sk/sk181127)
- Download Check Point R82 Gaia Fresh Install iso
  - https://support.checkpoint.com/results/download/135012
- Download Check Point R82 SmartConsole package
  - https://support.checkpoint.com/results/download/139568
- Check Point has begun blocking SmartConsole client downloads if you don't have an account
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
This Windows 11 workstation will be used to build  the environment and later manage it.

- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **win11-lan-ready**
  - Name: **checkpoint-console**
  - Description: **R82 Check Point SmartConsole**
  - First Interface:
    - Network: from the dropdown select the **Pool-wide network associated with eth0**
    - This will allow us to download files and packages all allow setting up the Check Point management network
    - We will disable this interface later
  - Second Interface:
    - Click **Add Interface**
    - Network: from the dropdown select the **Check Point Management**
    - This is the management network for the Check Point appliances
  - Advanced Settings
    - <i>Disable</i> "Enable VTPM" as we we cloning from an image that already has one
  - Click **Create**
- The details for the new Check Point VM are now displayed
- Click the **Console** tab and log in
- Change the IP address of the second interface to a static IP 192.168.103.100/24
  - Start > Settings > Network & internet
  - From the center pane click Ethernet
  - Network 2: set to Private network
  - Network 3: click on "Unidentified network"
  - IP assignment: click Edit
    - Set to Manual
    - Enable IPv4
    - IP address: 192.168.103.100
    - Subnet mask: 255.255.255.0
    - Gateway: blank
    - Preferred DNS: blank
    - DNS over HTTPS: off
    - click Save
  - DNS server assignment: Click Edit
    - Set to Manual
    - Enable IPv4
    - Preferred DNS: blank, DNS over https Off
    - Alternate DNS: blank, DNS over HTTPS Off
    - Click Save
- Download and install Winscp: https://winscp.net/eng/download.php
  - Typical installation with default settings suits our purposes
- Increase the display resolution to be able to use the firewall GUI properly

# Create Check Point Template
Comments on sizing (vCPU, RAM, storage):
- https://sc1.checkpoint.com/documents/R82/WebAdminGuides/EN/CP_R82_RN/Content/Topics-8RN/Open-Server-Hardware-Requirements.htm

Steps:
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **checkpoint-template**
  - Description: **R82 Check Point Template**
  - CPU: **4 vCPU**
    - A standalone gateway might run ok with 2 cores in some cases
  - RAM: **8GB** (more than R81.20)
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the Check Point Gaia ISO image you uploaded*
  - First Interface: eth0  = Mgmt
    - Network: from the dropdown select the **Check Point Management** network you created earlier
  - Second Interface: eth1 = eth1-Sync
    - Click **Add interface**
    - Network: from the dropdown select the **Check Point Sync** network you created earlier
  - Third Interface: eth2 = eth2
    - Click **Add interface**
    - Network: from the dropdown select the **pool-wide network associated with eth0**
    - This is the "Internet" for the Lab
  - Fourth Interface: eth3 = eth3
    - Click **Add interface**
    - Network: from the dropdown select the **Check Point Inside** network you created earlier
  - Fifth Interface: eth4 = eth4
    - Click **Add interface**
    - Network: from the dropdown select the **Check Point DMZ** network you created earlier
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
- Confirm the keyboard type **OK**
- Accept the default partitions sizing for 128GB drive
  - Swap: 8GB (6%)
  - Root: 20GB (16%)
  - Logs: 20GB (16%)
  - Backup and upgrade: 79GB (62%)
  - Feel free to customize
  - Choose **OK**
- Select a password for the "admin" account
- Select a password for <ins>maintenance mode "admin" user</ins>
- Select **eth0** as the management port
  - IP address: **192.168.103.254**
  - Netmask: **255.255.255.0**
  - Default gateway: **blank**
    - *will auto populate with 192.168.103.254, clear it*
  - NO DHCP server on the management interface
  - Select **OK**
- Confirm you want to continue with formatting the drive **OK**
- When the message `Installation complete.` message appears
  - Press enter
  - Wait for the system to start to reboot, then eject the ISO

## Set the Hostname
- Log in from the Console (username `admin` and the password you selected)
- `set hostname CPTEMPLATE`
- `save config`

## Install Guest Tools
- Configure the Check Point VM for copying the guest tools
  - Set the user shell to bash
    - `set expert-password`
      - select a password for "expert mode"
    - `save config`
    - `expert`
      - enter the password when prompted
    - `chsh -s /bin/bash admin`
- From checkpoint-console copy the guest tools to the Check Point VM
  - https://www.xenserver.com/downloads
  - Download XenServer VM Tools for Linux 8.4.0-1
  - Use WinSCP to copy the file to the Check Point VM
    - Open WinSCP
    - Hostname: 192.168.103.254
    - Username: admin
    - Password: the password you selected
    - Click **Login**
    - **Accept** the warnings, and **Continue**
    - Drag LinuxGuestTools-8.4.0-1.tar.gz file to the Check Point device's `/home/admin` folder
      - Click OK
  - Close WinSCP
- Configure Check Point VM to use the normal clish shell
  - continue where you were in expert mode
  - `chsh -s /etc/cli.sh admin`
- Install guest tools on the Check Point VM
  - `tar xzvf LinuxGuestTools-8.4.0-1.tar.gz`
  - `cd LinuxGuestTools-8.4.0-1`
  - `./install.sh -d rhel -m el8`
  - Press y to continue
- Optionally remove the guest tools tar file and the directory

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
  - Description: **R82 Check Point SMS**
  - CPU: **4 vCPU**
  - RAM: **8GB** (you may be able to test as low as 6GB in a Lab)
  - Interfaces: Remove all interfaces except **Check Point Management**
  - Click **Create**
- Log in at the console
- Configure hostname and IP address
  - `set hostname sms`
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
    - Name: **checkpoint-gw1-1**
    - Description: **R82 Check Point Gateway 1**
    - CPU: **4 vCPU**
    - RAM: **4GB**
    - Click **Create**
  - Disable TX Checksumming
    - Click the Network tab
    - Each interface has a blue gear icon to the right
    - For each interface, click the blue gear, click to disable TX checksumming, and click OK
  - Log in the console
  - Configure hostname and IP address
    - `set hostname gw1`
    - `set interface eth0 ipv4-address 192.168.103.1 mask-length 24`
    - `set interface eth0 comments "Management"`
    - `set interface eth0 state on`
    - `save config`
  - You can now ping the SMS: `ping 192.168.103.4`
- Create Gateway 2 (GW2)
  - From the left menu click **New** > **VM**
    - Select the pool **xcgp-ng-lab1**
    - Template: **checkpoint-template**
    - Name: **checkpoint-gw1-2**
    - Description: **R82 Check Point Gateway 2**
    - CPU: **4 vCPU**
    - RAM: **4GB**
    - Click **Create**
  - Disable TX Checksumming
    - Click the Network tab
    - Each interface has a blue gear icon to the right
    - For each interface, click the blue gear, click to disable TX checksumming, and click OK
  - Log in the console
  - Configure hostname and IP address
    - `set hostname gw1-2`
    - `set interface eth0 ipv4-address 192.168.103.1 mask-length 24`
    - `set interface eth0 comments "Management"`
    - `set interface eth0 state on`
    - `save config`
  - You can now ping the SMS: `ping 192.168.103.4`

# Set up SMS
- From `checkpoint-console` point browser to https://192.168.103.4 (the SMS web GUI)
  - Accept the self-signed certificate
- Log in as `admin` and the password you selected
- Complete First Time Configuration Wizard (FTCW) aka 'FTW'
  - Click **Next**
  - Continue with R82 configuration and **Next**
  - Management Connection
    - Add Default gateway **192.168.103.1**
    - Leave IPv6 Off
    - Click **Next**
  - Device Information
    - Host Name: **sms**
    - Domain Name: **xcpng.lab**
    - Primary DNS Server: 9.9.9.9 (for now; set to your internal DNS service later)
    - Secondary DNS Server: 1.1.1.1
    - Click **Next**
  - Date and Time Settings
    - Select **Use Network Time Protocol (NTP)** and select a time zone
    - Click **Next**
  - Select **Security Gateway and/or Security Management** and click **Next**
  - Products
    - Leave **Security Management** selected
    - <ins>Uncheck</ins> Security Gateway
    - Leave **Define Security Management as** set to **Primary**
    - Click **Next**
  - Security Management Administrator
    - Select **Define a new administrator**
      - Administrator: **cpadmin**
      - Password: *select a password*
      - Click **Next**
  - Security Management GUI Clients
    - Leave **Any IP Address** can log in for now
    - Will secure to the internal network or perhaps specific administrator IP addresses later
    - Click **Next**
  - Click **Finish**, then **Yes**
  - Wait patiently as the configuration is applied
  - When Configuration completed successfully is displayed, click **OK**
- You are now logged in to the Web GUI
- Next to *Manage Software Blades using SmartConsole* click **Download Now**

# Connect to the SMS
- Install the SmartConsole you downloaded from the Web GUI on the`checkpoint-console`
  - Check the box and click **Install**
  - Click **Finish**
- Login
  - Username: **cpadmin**
  - Password: *the password you selected*
  - Server Name or IP Address: **192.168.103.4**
  - Click **LOGIN**
- Accept the server fingerprint and **PROCEED**
- SmartConsole will update itself; click **Relaunch Now** when prompted
- NOTE There are a lot of "nag screens" to close out

Alternate management method: https://support.checkpoint.com/results/sk/sk170314
- Point your browser to https://192.168.103.4/smartconsole
- This is the web version of SmartConsole
- In our Lab testing, Web SmartConsole now works under R82
  - In R81.20, once the management server is connected to the Internet it can update and install Web SmartConsole
  - Web SmartConsole apparently runs in a Docker container

NOTE The SMS takes some time to start all the management processes after a reboot
- Check on SMS status from the checkpoint-sms command line: `api status`

# Set up Firewalls
References:
- https://sc1.checkpoint.com/documents/R82/WebAdminGuides/EN/CP_R82_ScalablePlatforms_AdminGuide/Content/Topics-SPG/ElasticXL/Working-with-ElasticXL.htm
- https://sc1.checkpoint.com/documents/R82/WebAdminGuides/EN/CP_R82_ScalablePlatforms_AdminGuide/Content/Topics-SPG/ElasticXL/ElasticXL-Getting-Started.htm

Here we will configure the first firewall in the cluster, then add to the SMS. Later add the second gateway to the ElasticXL cluster

## GW1 first Member
- From `checkpoint-console`, point browser to https://192.168.103.1
  - Accept the self-signed certificate
- Log in as `admin` and the password you selected
- Complete First Time Configuration Wizard (FTCW) aka 'FTW'
  - Click **Next**
  - Continue with R82 configuration and **Next**
  - Management Connection
    - Leave Default gateway blank
    - Leave IPv6 Off
    - Click **Next**
  - Internet Connection
    - Set interface to **eth2**
    - Configure IPv4: **Manually**
      - IPv4 address: *Select an IP address from your Lab network*
      - Subnet mask: *Use the same mask as your Lab network*
      - NOTE It is not recommended to use DHCP on the external interface
          - Before considering this, read up on [Dynamically Assigned IP Address (DAIP)](https://support.checkpoint.com/results/sk/sk167473)
    - Click **Next**
  - Device Information
    - Host Name: **gw1**
    - Domain Name: **xcpng.lab**
    - Primary DNS Server: 9.9.9.9 (for now; set to your internal DNS service later)
    - Secondary DNS Server: 1.1.1.1
    - Click **Next**
  - Date and Time Settings
    - Select **Use Network Time Protocol (NTP)** and select a time zone
    - Click **Next**
  - Select **Security Gateway and/or Security Management** and click **Next**
  - Products
    - Leave **Security Gateway** selected
    - <ins>Uncheck</ins> Security Mangement
    - Clustering
      - <i>Check</i> Unit is part of a cluster, type: **ElasticXL** (this is the new cluster mechanism; the old one in R81.20 is ClusterXL)
    - Click **Next**
  - Secure Communication to Management Server
    - Enter the SIC/Activation key twice (this is one time password, you will use it later)
      - Example: `xcplab123!`
    - Click **Next**
  - Click **Finish** and then **Yes**
  - Wait patiently as the configuration is applied
- Configure interfaces
  - Log back in https://192.168.103.1
  - From the left menu click **Network Management** > **Network Interfaces**
  - Mgmt - no IP address, member of bond magg1 (which has the management IP address)
  - eth2 is the Internet, already has IP address
  - Where is eth1? used for Sync
  - Compare with console interfaces:
    - Mgmt, Sync, eth1-Sync, eth2, lo, magg1
    - But when you try to use show interface, you can only select Mgmt, eth2, eth3, eth4, lo, magg1
  - Edit **eth3**
    - Enable: **Checked**
    - Comment: **Inside**
    - IPv4: Select **Use the following IPv4 address**
      - IPv4 address: **10.1.1.1**
      - Subnet mask: **255.255.255.0**
      - Yes this is the cluster virtual IP address
    - Click **OK**
  - Edit **eth4**
    - Enable: **Checked**
    - Comment: **DMZ**
    - IPv4: Select **Use the following IPv4 address**
      - IPv4 address: **192.168.102.1**
      - Subnet mask: **255.255.255.0**
      - Yes this is the cluster virtual IP address
    - Click **OK**
- Edit the Default Route
  - From the left menu click **Network Management** > **IPv4 Static Routes**
  - Click the "Default" route and then click **Edit**
  - Click **Add Gateway** > **IP Address**
  - Enter the default gateway IP address for your Lab network
  - Click **OK**
  - Click **Save**
- Test
  - From the gateway you can now ping the Internet and do nslookups

# Create Firewall Cluster in Smart Console
Yes, fully configure with one firewall. Will add the second gateway later.

## Create Cluster Object
- On `checkpoint-console`, Log in to SmartConsole again
- From the left menu, click **Gateways & Servers** (the default view when using SmartConsole for the first time)
- The **New** icon doesn't appear on smaller screens, click the "..." icon next to the Search bar to review more actions
- Click **New**  > **Gateway**
- Click **Classic Mode**
  - Cluster Name: **gw1** (best practice: same name as the appliance name)
  - Cluster IPv4 Address: use the managment IP address 192.168.103.1
  - Comment: **ElasticXL cluster**
    - Click **Communication...**
    - Activation Key: `xcplab123!` and confirm it
    - Click **Initialize**
    - Click **OK**
  - Click to **Close** the topology information
  - Click **OK** to acknowledge the threat preventions blades are active by default
  - Click **OK**, **Yes** to accept the portal message
- Double-Click the new **gw1** gateway you created
  - From the tree on the left, click **Network Management**
  - Edit eth2
    - Comments: **Internet**
    - Under Topology click **Modify**
    - Leads To:**Internet**
    - Security Zone: **According to topology: ExternalZone**
    - Click **OK** and **OK**
  - Edit eth3
    - Comments: **Inside**
    - Under Topology click **Modify**
    - Security Zone: **According to topology: InternalZone**
    - Click **OK** and **OK**
  - Edit eth4
    - Comments: **DMZ**
    - Under Topology click **Modify**
    - Leads To: **Override** > **This Network (Internal)** **Network defined by the interface IP and Net Mask**
    - Check **Interface leads to DMZ**
    - Security Zone: **According to topology: DMZZone**
    - Click **OK** and **OK**
  - Edit magg1
    - Comments: **Management**
    - Under Topology **click Modify**
    - Security Zone: **According to topology: InternalZone**
    - Click **OK** and **OK**
  - Click **OK**
- Re-open **gw1**
- General Properties
  - Leave **Monitoring** unchecked as it's not supported with ElasticXL
  - Leave IPSec VPN unchecked for this lab (feel free to experiment)
  - Optionally Check Application Control and URL Filtering if you would like to experiment 
- NAT
  - Check Hide internal networks behind the Gateway's external IP
    - This is acceptable for this Lab and cases where there are less than 50 hosts behind the firewall
- Network Management
  - If you have added additional routes for a complex topology, calculate the network topology from routes
    - Click Get Interfaces > Get Interfaces With Topology
- Click **OK** to close the gateway object
- Click **Publish**

# Create Network and Host Objects
- On `checkpoint-console`, Log in to SmartConsole again
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
- Close the command line api interface

TIP If you open this GitHub page from `checkpoint-console`, it's easy to copy/paste from there.

# Create Initial Policy
This policy is overly permissive, but it's a place to start.

- Click the Check Point menu button at top left then click **Manage Polices and Layers**
- Click the New icon under Policies
  - Name: **AccessPolicy**
  - Note that the default has the access control and threat prevention policies enabled
  - Click **OK** and then click **Close**
- From the left menu click **Security Policies**
- If not already selected, click on the policy **AccessPolicy** or click on "+" and open it
- Under **Access Control** click **Policy**
- Add first rule (at top) - Management
  - Name: Management rule
  - Source: SmartConsole (192.168.103.100)
  - Destinations: gw1
  - Services: https and ssh_version_2
  - Action: Accept
  - Track: Log
- Add second rule - Stealth
  - Name: Stealth rule
  - Source: *Any
  - Destinations: gw1
  - Services: *Any
  - Action: Drop
  - Track: Log
- Add third rule - Outbound Web Traffic
  - Name: Outbound Web Traffic
  - Source: InternalZone
  - Destinations: ExternalZone
  - Services: http and https
  - Action: Accept
  - Track: Log
- Add fourth rule - Inside to DMZ
  - Name: Internal to DMZ Web Traffic
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
  - First just install access policy
  - Next install both access policy and threat prevention policy

# Basic Testing
Test from `checkpoint-console`
- Change the Ethernet 3 adapter to have default gateway 192.168.103.1
- Disable Ethernet 2 adapter (the direct connection to the Lab network)
- Open a public web page such as https://ipchicken.com and test Internet access
- In SmartConsole, from the left menu click **Logs & Monitor**
- From the ribbon, click **Logs**
  - View the logs from the source "SmartConsole" 192.168.103.100
  - HHTP, HTTPS, and DNS are allowed
  - quic (udp/443) is not allowed
  - ICMP ping is not allowed

- Note that the management network is in the "InternalZone" due to the toplogy setting made on interface magg1

# Install Jumbo Hotfix on SMS
This method is from the command line on `checkpoint-sms`.It is possible to install the jumbo hotfix from the SMS web gui https://192.168.103.4 Software Update > Available Updates

You will select the jumbo hotfix by the number from the list of available updates.
- installer check-for-updates
- installer download [tab]
- installer download <number>
- installer verify [tab]
- installer verify <number>
- installer install [tab]
- installer install <number>
- accept the reboot
- after the sms reboots, allow 5 minutes for it to come back up

# Install Jumbo Hotfix on Single Gateway
For new ElasticXL clusters, it is recommended to install a jumbo hotbox on the single first gateway before adding any more gateways.
- Log in to SmartConsole
- Click **Gateways & Servers**
- Right-click gw1 > Install Hotfix/Jumbo...
- Install the recommended Jumbo (or install specific Hotfix/Jumbo)
- Click Verify
- Once it succeeds, click **Install**
- The gateway will reboot, and the update will succeed

# GW1 Second Member
NOTE We will be using the WebGUI method to add the second member. There is also a CLI process you can use.

- Prepare first gateway from console
  - `set lightshot-partition size 20`
  - `save config`
  - `reboot`
- Log in to the first gateway's managment IP
  - https://192.168.103.1
  - Click **Cluster Management**
  - Note the first gateway is there gw1-s0-01 (site one, number 1)
  - There are no pending gateways listed, so the second gateway isn't detected yet
- Log in to the second gateway's console (gw1-2 new member)
  - `expert`
  - `ifconfig -a`
    - note no IP address on eth1
  - vi /opt/ElasticXL/exl_detection/src/exl_detectiond.py
  - from
    - if __machine_info.sync_ifn != 'Sync' and not __machine_info.is_vmware and not __machine_info.is_kvm:
  - to
    - if False: #__machine_info.sync_ifn != 'Sync' and not __machine_info.is_vmware and not __machine_info.is_kvm
  - run this
    - dbset process:exl_detectiond t
    - dbset :save
    - tellpm process:exl_detectiond t
  - ifconfig will now show eth1 as 192.0.2.254
    - try ping 192.0.2.1 and from SMO ping 192.0.2.254
    - in testing, had to reboot the gateway for the IP to change and the ping test to work
    - however, the second appliance shows up as a pending gateway without requiring the reboot IF you apply the fix to the first gateway FIRST
- At this point the second gateway doesn't show up as a Pending Gateway, so repeat the change on the first gateway
- Log in to the first gateway's console (gw1)
  - `expert`
  - vi /opt/ElasticXL/exl_detection/src/exl_detectiond.py
  - from
    - if __machine_info.sync_ifn != 'Sync' and not __machine_info.is_vmware and not __machine_info.is_kvm:
  - to
    - if False: #__machine_info.sync_ifn != 'Sync' and not __machine_info.is_vmware and not __machine_info.is_kvm
  - run this
    - dbset process:exl_detectiond t
    - dbset :save
    - tellpm process:exl_detectiond t
- `reboot`
  - In testing, no reboot was required
- From `checkpoint-console` log in to https://192.168.103.1
- Click **Custer Management**
- Click **Pending Gateways**
- Select **Add to existing Site (Configuration load sharing with 1 Gateway in Site 1)** and click **Add**
- Click **OK** for the message *Add member request succeeded, the member's addition is in progress.*
- Wait patiently for the new member to be configured (including JHF packages)
  - The new gateway's name starts as *Not available* in the web GUI
  - Meanwhile logged into the SmartConnsole app, gw1 has an alert "Security Group - There is an effor on one or more sites"
  - This takes a very long time
  - PROBLEM the clone failed
    - see /var/log/lightshot.log file "Lightshot Partition is out of space"
    - during the clone operation there was a device out of space error logged, but all partitions showed space
    - retracing the log actions to view the lightshot partition
      - mount /dev/vg_splat/lv_log_lightshot /mnt/lightshot
      - df -h
      - /dev/mapper/vg_splat-lv_log_lightshot  14G  14G 124K  100% /mnt/lightshot
  - tried to remove the second member, but it didn't come back to pending; had to destroy and rebuild
- At this point we ran into some issues with the Lightshot partition running out of space
  - show lightshot-partition
    - gw1-1: availble 5.5G, required 10.684G, size 14G, used: 8.1G
    - gw1-2: available 0, required 9.004G, size 0, used: 0
  - Set lightshot partition on gw1-2
    - set lightshot-partition size 20
  - Set lightshot partion on SMO from gclish
    - set lightshot-partition size 20
    - save config
- Revert the changes to the exl_detectiond.py script
- Repeat on each member
  - `expert`
  - vi /opt/ElasticXL/exl_detection/src/exl_detectiond.py
  - from
    - if False: #__machine_info.sync_ifn != 'Sync' and not __machine_info.is_vmware and not __machine_info.is_kvm
  - to
    - if __machine_info.sync_ifn != 'Sync' and not __machine_info.is_vmware and not __machine_info.is_kvm:
  - run this
    - dbset process:exl_detectiond t
    - dbset :save
    - tellpm process:exl_detectiond t
- `reboot`
- Health checks
  - if you applied the jumbo hot fix prior to adding the second members, is the hotfix applied on both members?
    - Log in to WebGUI https://192.168.103.1 and check **Cluster Management**
  - `asg stat vs all`
  - from expert mode `hcp -r all`

# Install Jumbo Hotfix on All Gateways
In ElasticXL you need to follow the new rule:
- Do not install the hotfix on all the Security Group Members in a Security Group at the same time
- Prepare the package
  - Make sure you have the applicable CPUSE Offline package, put in /var/log
  - Connect to the command line on the Security Group
  - if you are in expert mode, run gclish
  - `installer import local /<Full Path>/<Name of the CPUSE Offline Package>`
  - `show installer packages imported`
  - `installer verify [Tab]`
  - `installer verify <number of the CPUSE package> member_ids all`
- Disable SMO image cloning feature
- Install the Hotfix on Security Group Members in logical group "A", then the remainder in logical group "B"
- Enable the SMO Image Cloning feature

Lab Instructions
- log in to SMO
- `installer check-for-updates`
- Download JHF
  - `installer download` [tab]
  - `installer download <package number>`
  - see also
    - `installer download <package number>` member_ids all`
    - `installer download `<package number>` member_ids 1_01`
    - `installer download `<package number>` member_ids 1_01-1_02`
    - `installer download `<package number>` member_ids 1_01,1_02`
- `show installer packages imported`
  - NOTE in testing it showed in second member, not not the first
- Verify JHF
  - installer verify [Tab]
  - installer verify `<number of the CPUSE package>`
  - see also
    - installer verify `<number of the CPUSE package>` member_ids all
    - installer verify `<number of the CPUSE package>` member_ids 1_01
    - installer verify `<number of the CPUSE package>` member_ids 1_01-1_02
    - installer verify `<number of the CPUSE package>` member_ids 1_01,1_02
- Disable SMO image cloning feature
  - show cluster configuration image auto-clone state
  - set cluster configuration image auto-clone state off
  - show cluster configuration image auto-clone state
  - NOTE In Lab testing the state was already off, not sure why
- Install the Hotfix on Security Group Members 1_01 (group "A")
  - log in to the console of gw1-1
  - `set cluster members-admin-state ids 1_01 down` and confirm
  - installer install [Tab]
  - installer install `<Number of CPUSE Package>` member_ids 1_01`
  - Accept the warning members will automatically reboot: y
  - Confirm that auto-clone is off: y
  - Confirm package installation: y
  - Enter your name when prompted
  - Enter a reason: Apply JHF
  - Monitor the system until security group members in logical group "A" are in the "UP" state
    - View from the SMO's WebGUI: https://192.168.103.1 > Cluster Management
    - Log in to gw1-2, the other member and monitor from CLI
      - `show cluster info overview live`
        - see also `show cluster`
- Install the Hotfix on Security Group Members 1_02 (group "B")
  - log in to the console of gw1-2
  - `set cluster members-admin-state ids 1_02 down`
  - installer install [Tab]
  - installer install `<Number of CPUSE Package>` member_ids 1_02`
  - Accept the warning members will automatically reboot: y
  - Confirm that auto-clone is off: y
  - Confirm package installation: y
  - Enter your name when prompted
  - Enter a reason: Apply JHF
  - Monitor the system until security group members in logical group "B" are in the "UP" state
    - View from the SMO's WebGUI: https://192.168.103.1 > Cluster Management
    - Log in to gw1-1, the other member and monitor from CLI
      - `show cluster info overview live`
        - see also `show cluster`
- Enable SMO image cloning feature
  - show cluster configuration image auto-clone state
  - set cluster configuration image auto-clone state on
  - show cluster configuration image auto-clone state
  - NOTE In Lab testing the state was already off, not sure why
- Make sure the Hotfix is installed on all Security Group Members
  - Log in to the WebGUI
    - Click Cluster Management
    - Note the version is listed for each member
  - Log in to command line
    - `show installer packages installed`
    - NOTE running `cpinfo -y all` from the command line on each member works too
  - NOTE in Lab testing, SmartConsole showed status of "-" and did not show the jumbo hotfix take
    - I have seen this in production Maestro environments as well; it seems to be a benign issue

# Add Windows 10 Workstation
- New > VM
- Pool **xcp-ng-lab1**
- Template: **win10-lan-ready**
- Name: **workstation1**
- Description: **Windows 10 on Check Point Inside network**
- Interfaces: Change to **Check Point Inside**
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
    - https://192.168.103.1
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
- Interfaces: Change to **Check Point DMZ**
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
  - Source: ExternalZone
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
  - http://192.168.102.10 - *works*
  - `http://<the IP address you assigned>`- *works*
- From a device in your Lab
  - `http://<the IP address you assigned>`
    - With ElasticXL I see the firewall logging accepted traffic
    - web page loaded after I cleared the cache/incognito mode
    - tcpdump on the web server shows the SYN and SYN/ACK packets
    - `fw ctl arp` shows the ARP entries for each member (yes two different proxy arps, one on each member)
    - Expert mode: g_tcpdump host 192.168.102.10
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

# Appendix
## Installing licenses on ElasticXL Cluster Members
- Connect an SSH client to the IP address of the ElasticXL Cluster.
  - Log in.
  - If you default shell is the Expert mode, then go to Gaia gClish:
    - gclish
- Get the MAC Addresses of the "magg1" interfaces from all ElasticXL Cluster Members and write them down:
  - show interface magg1 mac-addr
    - Example:
    - [Global] EXL-s01-01> show interface magg1 mac-addr
    - 1_01:
    - mac-addr XX:XX:XX:11:22:33
    - 1_02:
    - mac-addr XX:XX:XX:44:55:66
    - [Global] EXL-s01-01>
- In Check Point User Center, generate a license for each Security Appliance using these parameters:
  - IPv4 address of the ElasticXL Cluster.
    - This is the IPv4 address of the "Mgmt" interface of the first ElasticXL Cluster Member, on which you ran the Gaia First Time Configuration Wizard.
    - MAC Address of the "magg1" interface of each ElasticXL Cluster Member.
- Prepare the list of the required "cplic put" commands - for each generated license, you get an email from the User Center.
- Connect an SSH client to the IP address of the ElasticXL Cluster.
  - Log in.
- Run all the "cplic put" commands to install the licenses.
