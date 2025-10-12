# Install OPNsense firewall
OPNsense community edition is selected for the pentesting lab, mainly for its proven ability to secure handle all Internet traffic via Tor. Compared to pfSense, it is more user friendly and includes plugins for Xen tools and Tor. In contrast, pfSense CE is community based but pfSense+ is closed source. Downloaded even the free community edition requires going though the Netgate Store.

In this lab we will be using OPNsense 25.7

IMPORTANT You will have performance issues due to TX checksumming aka hardware checksum offloading. Where OPNsense is used as the external firewall, the usual approach on proxmox is to add a NIC and do PCI passthrough. Or it used to be the usual approach.

IMPORTANT If you are considering using OPNsense in production, be search to read this thread about OPNsense on proxmox: https://forum.opnsense.org/index.php?topic=44159.0

References:
- https://www.youtube.com/watch?v=-eqenlbBDLQ

# Configure Networking
Add a secured network behind the firewall for our pentesting environment

- Log in to proxmox
- From the left menu navigate to **Datacenter** > **proxmox-lab**
- Click on the host (**proxmox-lab**) to reveal the host settings
- Click **System** > **Network**
- Click **Create** > **Linux Bridge**
  - Name: **vmbr2**
  - Autostart: **Checked**
  - Click **Create**
- Click **Apply Configuration** and the new brige will start (next to Create/Revert in the menu bar)

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
- From the top ribbon click **Create VM**
  - General tab
    - Node: Auto selects **proxmox-lab**
    - VM ID: *automatically populated; each resource requries a unique ID* (up to 116)
    - Name: **opnsense**
    - Check Advanced and check **Start at boot**, consider setting start/shutdown order to **1**
  - OS tab (clicking Next takes you to the next tab)
    - Use CD/DVD disk image file (iso)
      - Storage: select the storage you are using
      - ISO image: select the ISO image you uploaded from the dropdown
    - Guest OS:
      - Type: Other (it's FreeBSD not Linux)
  - System tab
    - no changes (VirtIO SCSI single, i440fx, SeaBios)
    - don't check Qemu Agent, that will happen later
  - Disks tab
    - Bus Device: **SCSI**
    - Cache: **Write back**
    - Disk size: **32GB**
    - Check **Discard** because our host is using SSD's
  - CPU tab
    - Sockets: **1**
    - Cores: **4**
    - Type: **host**
      - IMPORTANT For best performance, you would set this to "Host" CPU type, as eliminates CPU emulation
      - if you don't care about performance leave at the default, i.e. x86-64-v2-AES
    - Advanced: enable **aes**
  - Memory tab
    - RAM: Recommended is **8192**MiB = 8GiB but for this lab we are using **4096**MiB = 4GiB
      - in testing we were able to build the firewall using 2GB of RAM despite the installer requiring 3000MiB to copy files
    - Advanced: <i>disable</i> Balooning Device (requires the VM to have all RAM available to it all the time, but you lose extra monitoring about memory usage)
  - Network tab
    - Bridge: **vmbr0**
    - VLAN Tag: no VLAN
    - Model: VirtIO (paravirtualized) for best performance
    - Firewall: uncheck
    - Multiqueue: 4 (to match our 4 CPU cores)
  - Confirm tab
  - <i>Don't</i> check **Start after created**
  - Click **Finish**
- Click on the new VM `opnsense`
- Click **Hardware**
- Click **Add** > **Network Device**
  - Bridge: **vmbr2**
  - Model: VirtIO (paravirtualized)
  - Firewall: uncheck
  - Multiqueue: 4 (to match our 4 CPU cores)
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
  - consumer SSDs will see more wear due to double synchronized writes
    - sudo apt-get install smartmontools
    - lsblk
      - look for device similar to nvme0n1
    - smartctl -a /dev/nvme0
- Accept the disk to install on
  - You need to check the box (use space bar)
  - **Yes**, accept erasing the disk
- Select a **Root Password** when prompted
- Select **Complete Install**
- Select **Halt now**
- Eject the ISO
  - Click on the VM
  - Click **Hardware**
  - Edit CD/DVD Drive
    - Do not use any media
- Start the VM and wait for the system to boot
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
    - Configure using DHCP: **No**
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
- Create a VM on the vmbr2 pentesting network
  - this VM will be able to access the OPNsense portal
  - Ubuntu Desktop or Windows 10 is perfect; a Kali Linux system is also perfect
  - For example, clone VM 107 (win10-desk)
    - Name: **win10-pen**
    - <ins>Change</ins> the network to bridge **vmbr2** (behind the OPNsense firewall, not VyOS router)
    - Note how it takes longer to clone a VM that is running
    - Start the VM and log in
    - **Yes**, allow the PC to be discovered
    - Confirm Internet access is working
- Initial firewall configuration
  - From VM's weg browser, log in to firewall https://192.168.101.254
    - Advanced > Continue
    - User `root` and password you selected
  - Follow the Wizard
    - General information
      - Hostname: **pentestfw**
      - Domain: **proxmox.lab**
      - DNS Servers: **8.8.8.8** and then **8.8.4.4** (we want unfiltered DNS for this network)
      - <ins>Uncheck</ins> Override DNS
      - Click **Next**
    - Configure WAN Interface
      - Type DHCP
      - <i>Uncheck</i> Block RFC1918 Private Networks since the "WAN" is connected to our lab which uses private RFC1918 address space
        - The default WAN settings will prevent the Pentesting network from accessing anything but the Internet
        - Explanation: By default RFC1918 networks (including 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16) are blocked on the WAN
    - Click Interfaces > WAN
    - <ins>Uncheck</ins> Block private networks
      - Click **Next**
    - Configure LAN Interface
      - Review and click **Next**
    - Set Root Password
      - Click **Next** to keep the existing password
    - Click **Apply**
  - Update OPNsense
    - Click **System** > **Firmware** > **Status**
    - Click **Check for Updates**
    - Read and accept the information provided
    - <i>Scroll to the bottom</i> of the Updates tab and click **Update** then accept the update and reboot
    - Wait for updates and reboot to complete
    - Log back in and check if there are any more updates
- Enable qemu guest agent
  - From OPNsense web GUI
    - System > Firmware > Plugins
    - Check **Show community plugins**
    - **os-qemu-guest-agent** - click "+" to install
    - **Power** > **Power Off**, click Yes (a simple restart is not sufficient)
  - From proxmox
    - click on VM opnsense
    - Options > QEMU Guest Agent
    - Change to Enabled (check Use QEMU Guest Agent)
    - Start VM opnsense
  - Confirm opnsense summary page shows IP addresses instead of "Guest Agent Not Running"
- Test Internet access from the pentesting network computer to confirm Internet access is still working
- Configure Firewall Rules
  - Log back in to OPNsense web GUI
    - https://192.168.100.254
  - Firewall > Rules
    - Clicking the interface (LAN, WAN, Loopback) or "Floating" allows you to view the default rules
  - Firewall > NAT
    - This allows you to view the default NAT rule under Outbound
  - Optionally change the IPv6 allow rule(s) from Pass to Block, then click **Apply Changes**
  - In a later step we will create rules to further isolate the pentesting network from the Lab network

# Isolate the Pentesting Lab
It is always best practice to operate in an isolated Pentesting network. If you must access the Internet, take precautions:
- Malicious traffic escaping the environment may expose you to prosecution and penalties
- Your ISP may find you in violation of their acceptable use policy
- Your activity is easily attributed to you and may draw attention from very anti-social netizens

Best practice is to pause and finish setting up any VMs you want to update over the Internet.
- you might build the VMs outside the pentesting network and move them into the isolated pentesting network
- you might also decide to not isolate the pentesting network until your systems are built

Now continue with the following steps to safely lock down the pentesting network.

## Disable Internet and DNS
Why are we disabling Internet DNS access? Because we only want traffic to get to the Internet via Tor.

- Log in to the console of the system on the pentesting network that you are using to configure OPNsense
- Firewall > Rules > LAN
  - Change the IPv4 rule to be a Block action
  - Change the IPv6 rule to be a Block action
  - Confirm what rules are needed
  - allow any to 127.0.0.1 port 9053? is that an auto rule?
  - allow any to 127.0.0.1 port 9040? is that an auto rule?
  - block all ipv4 and ipv6 from LAN net to everything
  - Click **Apply changes**
-  Confirm that Internet browsing fails and that nslookup from the command line also fails (i.e., 'nslookup google.com' times out)

2. On the OPNsense firewall block all traffic from 192.168.101.0/24 (LAN Net)
   - Firewall > Rules > LAN
   - Add rules
      - Block DNS traffic from 192.168.101.0/24 to the firewall
         - Action: Block
         - Interface: LAN
         - Protocol: TCP/UDP
         - Destination: This Firewall
         - Destination port range: DNS to DNS
         - Log: Log packets
         - Decription: block DNS covert channel
         - Why block DNS? DNS is used as a covert channel that operates through DNS to the Internet
         - Move to the top of the list
      - Allow other traffic from the pentest network to the firewall
         - Action: Pass
         - Source Interface: LAN
         - Protocol: any
         - Destination: This Firewall
         - Log: Log packets
   - Disable the rule "Default allow LAN to any rule"
   - Click **Apply changes**
 - Confirm that Internet browsing fails and that nslookup from the command line also fails (i.e., 'nslookup google.com' times out)

## Configure TOR
This provides some anonymity, if done correctly
- Configure the firewall to transparently proxy Internet traffic over Tor
- Be careful to <ins>configure DNS correctly</ins> to forward over Tor so your DNS traffic is not leaked
- You many choose to configure the firewall to instead use a VPN service; be mindful of the terms and conditions and that in some cases they will surrender details of your activity to under court order

References:
- https://docs.opnsense.org/manual/how-tos/tor.html
- https://forum.opnsense.org/index.php?topic=41550.0
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
- Click Services > Tor > Configuration
  - General Tab
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
  - SOCKS Proxy ACL
    - Add a new ACL
      - Enable: /Yes
      - Protocol: !Pv4
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
    - Destination port range: any to any
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
    - Quick: Checked
    - Interface: LAN
    - Direction: in
    - TCP/IP Version: IPv4
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
  - Power > Reboot > confirm

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
    - tcpdump -nni vtnet0 port 53
  - next check for icmp ping leak by running tcpdump while you test pings to the Internet (i.e., `ping 8.8.8.8`)
  - finally check for udp leaks by running tcpdump and generating QUIC udp/443 traffic
    - install Chrome
    - chrome://flags
    - Search for Experimental QUIC protocol; in the dropdown next to it select Enabled
    - Click Relaunch at the bottom to restart Chrome
    - Browse google.com or other Google web properites to generate QUIC traffic which will be dropped by the firewall
    - tcpdump -nni vtnet0 proto 17 and port 443
- REMEMBER Tor supports TCP only; if you need udp traffic to the Internet from the lab, consider using a VPN instead of Tor
