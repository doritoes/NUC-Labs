# Install OPNsense firewall
OPNsense community edition is selected for the pentesting lab, mainly for its proven ability to secure handle all Internet traffic via Tor. Compared to pfSense, it is more user friendly and includes plugins for Xen tools and Tor.In contrast, pfSense CE is community based but pfSense+ is closed source. Downloading even the free community edition requires going though the Netgate Store.

In this lab we will be using OPNsense 25.7

IMPORTANT Be sure to <ins>disable TX checksumming</ins> on the network interfaces connected to the firewall as noted below.

References:
- https://www.youtube.com/watch?v=KecQ4AZ-RBo
- https://docs.xcp-ng.org/guides/pfsense/
- https://xcp-ng.org/docs/networking.html#vlans
- https://community.spiceworks.com/t/opnsense-transparent-bridge-between-isp-and-fortigate/946090/8

# Configure Networking
- Log in to Xen Orchestra (XO)
- Configure networks
  - From the left menu click **Home** > **Hosts**
  - Click on the host you configured (i.e., **xcp-ng-lab1**)
  - Click the **Network** tab
  - Under Private networks click **Manage**
    - Click **Add a Network**
      - Interface: **eth0**
      - Name: **Pentesting**
      - Description: **Inside Pentesting Network**
      - MTU: *leave blank* (default 1500)
      - VLAN: **200**
      - NBD: **No NBD Connection** (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
      - Click **Create network**
    - Renavigate to **Home** > **Hosts** > **xcp-ng-lab1** > **Network**

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
- From the left menu Click Import > Disk
- Select the SR from the dropdown, LOCAL-ISO
- Drag and drop the vyos ISO file in the box
- Click Import

# Create OPNsense VM
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **opnsense**
  - Description: *opnsense pentesting Lab firewall*
  - CPU: **4 vCPU**
  - RAM: **4GB** (recommended is 8GB, but for this lab we are using 4GB, warnings appear for less than 3GB)
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the OPNsense ISO image you uploaded*
  - First Interface:
    - Network: from the dropdown select the **pool-wide host network (eth0)**
  - Second Interface: Click **Add interface**
    - Network: from the dropdown select the **Pentesting** network you created earlier
  - Disks: Click **Add disk**
    - Add **32GB** disk
  - Click **Show advanced settings**
    - Check **Auto power on**
  - Click **Create**
- The details for the new OPNsense VM are now displayed
- Click the **Network** tab
  - Next to each interface is a small settings icon with a blue background
  - For every interface click the gear icon then <ins>disable TX checksumming</ins>
- Click **Console** tab and watch as the system boots

# Configure OPNsense
- Log in as `installer`/`opnsense`
- Select the keymap
- **Install (ZFS)** - it is the best choice for the Lab
  - stripe - no redundancy (for our Lab this is fine)
  - uses slightly more RAM for the ARC (adaptive replacement cache) process
  - much more stable under power failure or hard reboots
- Accept the disk to install on
  - You need to check the box (use space bar)
  - **Yes**, accept erasing the disk
- Select a **Root Password** when prompted
- Select **Complete Install**
- Select **Reboot now**
- Eject the ISO once the reboot starts (click the eject icon on Console tab)
- Wait for the system to boot
- Log in as `root` with the selected password (default password is `opnsense`)
- Option 1) **Assign interfaces**
  - LAGGs: **No**
  - VLANs: **No**
  - WAN interface: **xn0**
  - LAN interface: **xn1**
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
  - From the left menu click **New** > **VM**
  - Select the pool **xcp-ng-lab1**
  - Select the **win11-lan-ready** or **ubuntu-desktop-lab** template
  - Name: **pentest-workstation**
  - <ins>Change</ins> the Interface to **Pentesting**
  - Click **Create**
- Initial firewall configuration
  - From VM's browser, log in to firewall https://192.168.101.254
    - User `root` and password you selected
  - Follow the Wizard
    - General information
      - Hostname: **pentestfw**
      - Domain: **xcpng.lab**
      - DNS Servers: **8.8.8.8** and **8.8.4.4** (we want unfiltered DNS for this network)
      - <ins>Uncheck</ins> Override DNS
      - Click **Next**
    - Configure WAN Interface
      - Type DHCP
      - <i>Uncheck</i> Block RFC1918 Private Networks since the "WAN" is connected to our lab which uses private RFC1918 address space
        - The default WAN settings will prevent the Pentesting network from accessing anything but the Internet
        - Explanation: By default RFC1918 networks (including 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16) are blocked on the WAN
    - Configure LAN Interface
      - Review and click **Next**
    - Set Root Password
      - Click **Next** to keep the existing password
    - Click **Reload**
  - Update OPNsense
    - Click **System** > **Firmware** > **Status**
    - Click **Check for Updates**
    - Read and accept the information provided
    - Scroll to the bottom of the Updates tab and click **Update** then accept the update and reboot
    - Wait for updates and the reboot to complete
    - Log back in and check if there are any more updates
  - Install Xen guest utilities
    - System > Firmware > Plugins
      - Check **Show community plugins**
      - **os-xen** - click "+" to install
      - Reboot (**Power** > **Reboot** > **Yes**)
    - In XO, look at the opnsense VM general tab; management agent is now detected
- Test Internet access from the pentesting network computer to confirm Internet access is still working
- Configure Firewall Rules
  - Log back in to OPNsense web GUI
    - https://192.168.101.254
  - Firewall > Rules
    - Clicking the interface (LAN, WAN, Loopback) or "Floating" allows you to view the default rules
  - Firewall > NAT
    - This allows you to view the default NAT rule under Outbound
  - The default WAN settings will prevent the Pentesting network from accessing anything but the Internet
    - Explanation: By default RFC1918 networks (including 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16)
  - Because our "WAN" is on a RFC1918 network, double check this setting
    - Click Interfaces > WAN
    - <i>Uncheck</i> Block private networks
    - Click **Save**
    - Click **Apply Changes**
  - Optionally change the IPv6 allow rule(s) from Pass to Block, then click **Apply Changes**
  - In a later step we will create rules to further isolate the pentesting network from the Lab network

# Isolate the Pentesting Lab
It is always best practice to operate in an isolated Pentesting network. If you must access the internet, take precautions:
- Malicious traffic escaping the environment may expose you to prosecution and penalties
- Your ISP may find you in violation of their acceptable use policy
- Your activity is easily attributed to you and may draw attention from very anti-social netizens

Best practice is to stop and finish setting up any parts you want to update over the Internet. The [next section](7_Pentesting_Lab.md) requires some of that.

Then continue with the following steps to lock things down safely.

## Disable Internet and DNS
Why are we disabling Internet including DNS access? Because we only want traffic to get to the Internet via Tor. DNS leaks data about your activity and is used as a covert channel that operate through DNS to the Internet.

- Log in to the console of the system on the pentesting network that you are using to configure OPNsense
- Firewall > Rules LAN
  - Change the IPv4 rule to be a Block action
  - Change the IPv6 rule to be a Block action
  - Click **Apply changes**

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
- From the pentest network VM's browser log in to OPNsense (https://192.168.101.254)
- System > Firmware > Plugins
  - Check Show community plugins
  - os-tor - click "+" to install
- Refresh the page
- Click Services > Tor > Configuration > General
  - Enable: Yes
  - Listen Interfaces: LAN (only)
  - Optionally enable Create a logfile with Error of Debugging level (WARNING this could cause privacy issues)
  - Enable Advanced Mode
    - Confirm SOCKS port number: 9050
    - Confirm Control Port: 9051
    - Check Enable Transparent Proxy
    - Confirm Transparent port: 9040
    - Confirm Transparent DNS port: 9053
  - Click Save
- Services > Tor > Configuration > SOCKS Proxy ACL
    - Add a new ACL
      - Enable: Yes
      - Protocol: IPv4
      - Network: 192.168.101.0/24
      - Action: Accept
      - Click Save
      - Click Reload Service
  - Firewall > NAT  > Port Forward
    - Add a rule
    - Disabled: No
    - Interface: LAN (only)
    - TCP/IP Version: IPv4
    - Protocol: TCP/IP
    - Source: Advanced > LAN net
    - Destination: any
    - Destination port range: DNS to DNS
    - Redirect target IP: 127.0.0.1
    - Redirect target port: other: 9053
    - Log: only enable logging for troubleshooting; this takes up extra space on the firewall
    - Description: Use Tor for DNS
    - Click **Save**
  - Add rule below (at the end)
    - Disabled: No
    - Interface: LAN (only)
    - TCP/IP Version: IPv4
    - Protocol: TCP
    - Source: Advanced > LAN net
    - Destination: any
    - Destination port range: any to any
    - Redirect target IP: 127.0.0.1
    - Redirect target port: other: 9040
    - Log: only enable logging for troubleshooting; this takes up extra space on the firewall
    - Description: Use Tor for tcp traffic
  - NOTE that Tor is TCP only except for DNS; you should block other UDP ports on the firewall, especially QUIC (udp/443) and udp/80
  - Click **Apply changes**
- Firewall > Rules > LAN
  - Move the automatic rules to the top
  - First, allow any to 127.0.0.1 port 9053
  - Next, allow any to 127.0.0.1 port 9040
  - The last two rules should be block rules
- Firewall > Rules > WAN
  - While we are here, we can clean up the logs by NOT logging our lab network mDNS to get logged on the OPNsense firewall
  - Add rule
    - Action: Block
    - Disabled: Unchecked
    - Quick: Checked
    - Disabled: No
    - Interface: WAN
    - Direction: in
    - TCP/IP Version: IPv4
    - Protocol: UDP
    - Source: any
    - Destination: Single host or Network: 224.0.0.251
    - Destination port range: (other) 5353 to (other) 5353
    - Log: No
    - Description: Do not log mDNS drops
    - Click **Save** then click **Apply changes**
- Reboot the firewall
  - Power > Reboot > **Yes**

### Test TOR access
- Using the pentest VM's browser connect to https://check.torproject.org
  - You should see "Congratulations. This browser is configured to use Tor."
- From VM's browser, check the public IP address <ins>with</ins> Tor
  - http://ipchicken.com
- Try updating your VM's OS using toor (Linux example below)
  - `sudo apt update && sudo apt upgrade -y`
  - Note that everything is slower over Tor
- Check for leaks (privacy issues)
  - on firweall, do a tcpdump to check for any DNS queries going out while you browser the internet and do nslookups
    - `tcpdump -nni vtnet0 port 53`
  - next check for icmp ping leak by running tcpdump while you test pings to the Internet (i.e., `ping 8.8.8.8`)
    - `tcpdump -nni vtnet0 icmp`
  - finally check for udp leaks by running tcpdump and generating QUIC udp/443 traffic
    - install Chrome
    - chrome://flags
    - Search for Experimental QUIC protocol; in the dropdown next to it select Enabled
    - Click Relaunch at the bottom to restart Chrome
    - Browse google.com or other Google web properites to generate QUIC traffic which will be dropped by the firewall
    - `tcpdump -nni vtnet0 proto 17 and port 443`
- REMEMBER Tor supports tcp only; if you need udp traffic to the Internet from the lab, consider using a VPN instead of Tor
