# Install OPNsense firewall
OPNsense community edition is selected for the pentesting lab, mainly for its proven ability to secure handle all Internet traffic via Tor. Compared to pfSense, it is more user friendly and includes plugins for Xen tools and Tor.

📓 This Lab was built using OPNsense-24.1. Soon after 24.7 was released with a complete re-work of the interface. Re-deploying the lab using 

IMPORTANT You will have performance issues duo to TX checksumming aka hardware checksum offloading. Where OPNsense is used as the external firewall, the usual approach on proxmox is to add a NIC and do PCI passthrough.

References:
- to do

# Configure Networking
- Log in to proxmox
- From the left menu navigate to Datacenter > proxmox-lab1
- Click on the host (proxmox-lab1) to reveal the host settings
- Click **System** > **Network**
- Click **Create** > **Linux Bridge**
  - Name: **vmbr2**
  - Autostart: **Checked**
  - Click **Create**
- Click **Apply Configuration** and the new brige will start

# Download the ISO
1. Go to https://opnsense.org/download/
    - Architecture: amd64
    - Image type: dvd
    - Mirror: select a mirror close to you geographically
    - Click Download
      - the file is a .bz file
      - for our lab purposes, we do not need to validate the image
2. Unpack the image
    - Unix-like: `bzip2 -d OPNsense-<filename>.bz2`
    - Windows: use [7-zip](https://www.7-zip.org/)
    - resulting file will be a .iso file

# Upload the ISO
If you linked storage to a file share, copy the file there.

Or, if you created local storage, upload the ISO there.
- From the left menu expand Datacenter > proxmox-lab
- Click local (proxmox-lab)
- Click ISO Images
- Click Upload and follow the prompts

# Create OPNsense VM
- From the top ribbon clicc **Create VM**
  - General tab
    - Node: Auto selects **proxmox-lab1**
    - VM ID: automatically populated; each resource requries a unique ID
    - Name: **opnsense**
    - Check **Start at boot**
  - OS tab (clicking Next takes you to the next tab)
    - Use CD/DVD disk image file (iso)
      - Storage: local
      - ISO image: select the image you uploaded from the dropdown
    - Guest OS:
      - Type: Linux
      - Version: 6.x - 2.6 Kernel
  - System tab
    - no changes for OPNsense
  - Disks tab
    - Disk size: **20GB**
    - Check **Discard** because our host is using SSD's
  - CPU tab
    - Sockets: **1**
    - Cores: **4**
    - Type: Leave at the default (my Lab it's x86-64-v2-AES)
  - Memory tab
    - RAM: **2048**MiB = 2GiB
  - Network tab
    - Bridge: vmbr0
    - VLAN Tag: no VLAN
    - Model: VirtIO (best performance)
    - Firewall: default is checked, <ins>uncheck</ins> for the router
    - Add vmbr2
  - Confirm tab
  - Don't check **Start after created**
  - Click **Finish**
- Click on the new VM **opnense**
- Click **Hardware**
- Click **Add** > **Network Device**
  - Bridge: **vmbr2**
  - Uncheck Firewall
  - Click **Add**

# Configure OPNsense
- Start VM **opnsense**
- Click on **Console**
- Log in as `installer`/`opnsense`
- Select the keymap
- **Install (ZFS)** - it is the best choice for the Lab
  - stripe - no redundancy (for our Lab this is fine)
  - uses slightly more RAM for the ARC (adaptive replacement cache) process
  - much more stable under power failure or hard reboots
- Accept the disk to install on
  - You need to check the box (use space bar)
  - Accept erasing the disk
- Select a root password when prompted
- Select **Complete Install**
- Eject the ISO once the reboot starts
  - Click on the VM
  - Click Hardware
  - Edit CD/DVD Drive
    - Do not use any media
- Wait for the system to boot
- Log in as `root` with the selected password (default password is `opnsense`)
- Option 1) **Assign interfaces**
  - LAGGs: **No**
  - VLANs: **No**
  - WAN interface: **vtnet0**
  - LAN interface: **vtnet1**
  - Optional (OPT1): *just press enter*
  - Confirm
- Option 2) **Set interface IP address**
  - Configure **LAN**
    - DHCP: **No**
    - IPv4 address: **192.168.101.254**
    - Subnet mask CIDR: **24**
    - Press enter to confirm no upstream gateway on the LAN interface
    - IPv6: No two times, and press enter to confirm no IPv6 address
    - Enable DHCP server on LAN: **Yes**
    - Client address start: **192.168.101.20**
    - Client address end: **192.168.101.250**
    - Change web GUI protocol to http: **No**
    - Generate new self-signed web GUI certificate: **Yes**
    - Restore web GUI access defaults: **No**
  - Configure **WAN**
    - DHCP: **Yes**
    - IPv6: No, and press enter to confirm no IPv6 address
    - Change web GUI protocol to HTTP: **No**
    - Generate a new self-signed web GUI certificate: **No**
    - Restore web GUI access defaults: **No**
- Create a VM on the Pentesting network
  - Ubuntu Desktop or Windows 10 is perfect; a Kali Linux system is also perfect
  - Create a new VM or clone an existing one
  - <ins>Change</ins> the network  to bridge **vmbr2**
- Initial firewall configuration
  - From VM's browser, log in to firewall https://192.168.101.254
    - User `root` and password you selected
  - Follow the Wizard
    - General information
      - Hostname: **pentestfw**
      - Domain: **proxmox.lab**
      - Primary DNS Server: **8.8.8.8** (we want unfiltered DNS for this network)
      - Secondary DNS Server: **8.8.4.4**
      - <ins>Uncheck</ins> Override DNS
      - Click **Next**
    - Time server information
      - Leave the default time server
      - Optionally adjust the Timezone
      - Click **Next**
    - Configure WAN Interface
      - Review the information, default values are OK
      - Click **Next**
    - Configure LAN Interface
      - Review and click **Next**
    - Set Root Password
      - Click **Next** to keep the existing password
    - Click **Reload**
  - Update OPNsense
    - Log back in
    - Click **System** > **Firmware** > **Status**
    - Click **Check for Updates**
    - Read and accept the information provided
    - Scroll to the bottom of the Updates tab and click **Update** then accept the update and reboot
    - Wait for updates and the reboot to complete
    - Log back in and check if there are any more updates
- Configure Firewall Rules
  - Firewall > Rules
    - Clicking the interface (LAN, WAN, Loopback) or "Floating" allows you to view the default rules
  - Firewall > NAT
    - This allows you to view the default NAT rule under Outbound
  - The default WAN settings will prevent the Pentesting network from accessing anything but the Internet
    - Explanation: By default RFC1918 networks (including 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16)
  - Because our "WAN" is on a RFC1918 network
    - Click Interfaces > WAN
    - Uncheck Block private networks
    - Click Save
    - Click Apply Changes
  - Optionally change the IPv6 allow rule(s) from Pass to Block, then click **Apply Changes**

# Isolate the Pentesting Lab
It is always best practice to operate in an isolated Pentesting network. If you must access the internet, take precautions:
- Malicious traffic escaping the environment may expose you to prosecution and penalties
- Your ISP may find you in violation of their acceptable use policy
- Your activity is easily attributed to you and may draw attention from very anti-social netizens

Best practice is to stop and finish setting up any parts you want to update over the Internet.

Then continue with the following steps to lock things down safely.

## Disable Internet and DNS
1. On the OPNsense firewall block all traffic from 192.168.101.0/24 (LAN Net)
2. Block DNS traffic from 192.168.101.0/24 to the firewall
    - Why block DNS? DNS is used as a covert channel that operate through DNS to the Internet
## Configure TOR
This provides some anonymity, if done correctly.
- Configure the firewall to transparently proxy Internet traffic over Tor
- Be careful to <ins>configure DNS correctly</ins> to forward over Tor so your DNS traffic is not leaked
- You many choose to configure the firewall to instead use a VPN service; be mindful of the terms and conditions and that in some cases they will surrender details of your activity to under court order

References:
- https://docs.opnsense.org/manual/how-tos/tor.html
- https://cybernomad.online/dark-web-building-a-tor-gateway-7a7dfa45884f
- https://www.youtube.com/watch?v=4K2YuWp2GB4
- https://forum.opnsense.org/index.php?topic=15097.0
- https://docs.huihoo.com/m0n0wall/opnsense/manual/how-tos/tor.html

Steps:
- From VM's browser, check the current public IP address, without TOR
  - http://ipchicken.com
- Log in to firewall https://192.168.101.254
- System > Firmware > Plugins
  - os-OPNproxy - click "+" to install
    - this doesn't seem to help, but it does seem to replace the old Services > Web Proxy functionality
    - Servcies > Squid Web Proxy > Administration
      - Enable proxy and click Apply
      - Click Forward proxy
        - Proxy interfaces: LAN
        - Check Enable Transparent HTTP proxy
        - Click Apply
  - os-tor - click "+" to install
- Refresh the page
- Click **Services** > **Tor** > **Configuration**
  - General Tab
    - Enable: Yes
    - Listen Interfaces: LAN
    - Enable Advanced Mode
      - Check **Enable Transparent Proxy**
      - Confirm SOCKS port number: 9050
      - Confirm Control Port: 9051
      - Confirm Transparent port: 9040
      - Confirm Transparent DNS port: 9053
  - Click **Save**
- **Firewall** > **Rules** > **LAN**
  - Add rule to top of policy
    - Action: Pass
    - Quick: Checked
    - Interface: LAN
    - Direction: in
    - TCP/IP Version: IPv4
    - Protocol: TCP/UDP
    - Source: LAN net
    - Destination: This Firewall
    - Destination port range: From 53 to 53 (DNS)
    - Log: This is not recommended for this Lab, but enable if you wish
    - Description: Allow DNS to firewall
    - Click Save
    - Move the new rule to the top if necessary
      - Put a Check next to new rule Allow DNS to Firewall
      - Click the arrow icon to the right of the first rule to move it to the top
    -  Allow LAN net to This Firewall IP for TCP/IP DNS
  -  Add a second rule just below it
      - Action: Block
      - Quick: Checked
      - Interface: LAN
      - Direction: in
      - TCP/IP Version: IPv4
      - Protocol: TCP/UDP
      - Source: LAN net
      - Destination: any
      - Destination port range: From 53 to 53 (DNS)
      - Log: This is not recommended for this Lab, but enable if you wish
      - Description: Deny unsanctioned DNS
      - Click Save
    - Move the new rule below the first rule if necessary
      - Put a Check next to new rule Deny unsanctioned DNS
      - Click the arrow icon to the right of the <ins>second</ins> rule to move it to the second position
    -  Allow LAN net to This Firewall IP for TCP/IP DNS
  - Click Apply Changes
- **Firewall** > **NAT** > **Port Forward**
  - Add rule
    - Click the "+" to add a rule
    - Interface: **LAN** (be sure you ONLY select LAN)
    - TCP/IP Version: **IPv4**
    - Protocol: **TCP** (TOR rejects UDP packets except for DNS requests)
    - Source: **LAN net**
    - Source port range: **any**
    - Destination: **ANY**
    - Destination Port: **ANY**
    - Redirect Target IP: Single Host or Network: **127.0.0.1**
    - Redirect Target Port: (other) **9040** (this is the Transparent TOR port)
    - Log: This is not recommended for this Lab, but enable if you wish
    - Description: **Port forward to Tor**
    - NAT reflection:
      - System default ?
    - Filter rule association:
      - (default) add associated filter rule, didn't work
      - trying None
    - Click **Save**
    - Click **Apply changes**
- Reboot the firewall
  - Power > Reboot > confirm
- Using your browser connect to https://check.torproject.org
  - You should see "Congratulations. This browser is configured to use Tor."
  - Having issues connecting to the Internet?
    - If may take a moment for the Tor circuits to be build
      - Services > Tor > Diagnostics > Circuits
    - Is DNS working from the command line, but you don't have web access?
      - check the NAT: Port Forward rule <ins>carefully<ins>
      - check Tor configuration
    - restart Tor: Lobby > Dashboard > Under services, find the restart button next to tor

### Test TOR access
- From VM's browser, check the public IP address <ins>with</ins> TOR
  - http://ipchicken.com
- Try updating your VM's OS
  - `sudo apt update && sudo apt upgrade -y`
  - Note that everything is slower over Tor

### Confirm privacy
TCP dump on lab firewall for the OPNsense firewall and port 53. if it's using port 53 it could be leaking DNS lookups. in that case  NAT port 53 TCP/UDP on the interface used for Tor to 127.0.0.1:9053 to prevent DNS leaks.

Now test `ping` commands to the Internet. Are they leaking outside the tunnel?