# Appendix - L2 Firewall
OPNsense supports a "transparent filtering bridge", which is elsewhere called a Layer 2 (L2) firewall. A Layer 2 firewall does not perform routing nor NAT. It is deployed between two devices on the same LAN, filtering traffic without creating different subnets.

For example, you want to isolate a device while keeping it on the same LAN.

References:
- https://docs.opnsense.org/manual/how-tos/transparent_bridge.html
- https://forum.opnsense.org/index.php?topic=49704.0
- https://docs.opnsense.org/manual/how-tos/lan_bridge.html

Warnings:
- L2 firewall not compatible with traffic shaping
- Most L2 firewalls cannot do IPS; needs confirmation for OPNsense

Overview:
- Using OPNsense 25.7
- Start from a default installation on a virtual device with 3 interfaces
- Disable DHCP server on LAN
- Create a Bridge interface and assign a management IP address to it
- Enable setting to allow filtering on bridge interfaces
- Modify Allow rules

# Download the ISO
- https://opnsense.org/download/
  - select image type: **dvd** and click **Download OPNsense**
- Extract the ISO file from the .bz2 archive using a tool like 7-Zip
- Add the ISO file to the ISO store in XCP-ng

# Modify the Network
- Add a private network for the secured host(s)
  - Home > Hosts > xcp-ng-lab1
  - Network > Manage
  - Add a network
    - Interface: *leave blank*
    - Name: L2net
    - Description: Layer 2 bridged network off lab
    - NBD: No NBD Connection

# Create OPNSense VM
- From the left menu click **New** > **VM**
  - Select the pool **xcp-ng-lab1**
  - Template: **Other install media**
  - Name: **opnsenseL2**
  - Description: *OPNsense Layer 2 firewall*
  - CPU: **4 vCPU**
  - RAM: **4GB** (recommended is 8GB, but for this lab we are using 4GB; warnings appear for less than 3GB)
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the OPNsense ISO image you uploaded*
  - First Interfaces:
    - Network: from the dropdown select the **pool-wide host network (eth0)**
  - Second Interface: Click **Add interface**
    - Network: from the dropdown select the **L2net**
  - Third Interface: Click **Add interface**
    - Network: from the dropdown select the **pool-wide host network (eth0)**
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

# Install OPNsense
- Log in as `installer`/`opnsense`
- Select the keymap
- **Install (ZFS)** - it is the best choice for the Lab
  - stripe - no redundancy (for our Lab this is fine)
  - uses slightly more RAM for the ARC (adaptive replacement cache) process
  - much more stable under power failure or hard reboots
- Accept the disk to install on
  - You need to check the box (use space bar)
  - **Yes**, accept erasing the disk
- Be patient as installation proceeds
- Select **Root Password** and select a password
- Select **Complete Install**
- Select **Reboot now**
- Eject the ISO once the reboot starts (click the eject icon on Console tab)
- Wait for the system to boot

# Configure OPNsense
- Log in to Console user `root` with the password you selected
- `1) Assign interfaces`
  - LAGGs? **No**
  - VLANs? **No**
  - WAN interface name: **none** (press enter)
  - LAN interface name: **xn0**
  - Optional interfaces:
  - OPT1 interface name: **xn1**
  - OPT2 interface name: **xn2**
  - Optional interface: *just press enter*
  - Proceed: **Yes**
- `2) Set interface IP addresses`
  - LAN
    - Configure IP via DHCP? **No**
    - LAN IPv4 Address: **192.168.1.150** (an IP address on your Lab network)
    - Mask bits: **24** (to match your Lab network)
    - Upstream gateway: *press Enter to accept no gateway*
    - IPv6 address: **No**, **None** (press Enter)
    - Enable DHCP server on LAN: **No**
    - Change to HTTP: **No**
    - Generate new self-signed web GUI certificate? **No**
    - Restore web GUI defaults? **No**
  - WAN
    - there is no WAN
  - OPT
    - no IP addresses on the OPT interfaces
- System: Configuration: Wizard
  - Log in to the firewall using the IP address you set (i.e., https://192.168.1.150)
  - Click **Next** to start the Wizard
  - General Information tab
    - Hostname: **l2firewall**
    - Domain: **xcpng.lab**
    - Optionally set Timezone
    - DMZ: **9.9.9.9**, **1.1.1.1** (feel free to customize)
    - <ins>Uncheck</ins> Override DNS
    - <ins>Uncheck</ins> Enable Resolver
    - Click **Next**
  - Network [WAN] tab
    - Type: DHCP (since there is no WAN interface, this is the easiest option)
    - Oddly it still asks for an IP address(!); in Lab use **4.4.4.4/32** (yes it's a DNS server, we will delete the WAN interface completely)
    - **Don't block** RFC1918 private networks or bogon networks
    - Click **Next**
  - Network [LAN] tab
    - <ins>Uncheck</ins> Configure DHCP server
    - Click **Next**
  - Set initial password tab
    - Click **Next** to leave password the same
  - Click **Apply** to finish the wizard
- Interfaces > Assignments
  - Delete WAN interface
  - Click Save
- Create the bridge
  - Interfaces > Devices > Bridge
  - ADD a new bridge
  - Select OPT1 and OPT2
  - Optionally add a description
  - Click **Save**
  - Click **Apply**
- The OPT1 and OPT2 interfaces should NOT have any IP address configuration
  - they should be enabled by default, that's it
- Interfaces > Assignments
  - Change LAN to bridge0 (bridge)
  - Click **Save**
- System Tunables
  - System > Settings > Tunables
    - Add two tunables, saving each
    - net.link.bridge.pfil_member = 0
      - Set to 0 to disable filtering on the incoming and outgoing member interfaces
    - net.link.bridge.pfil_bridge = 1
      - Set to 1 to enable filtering on the bridge interfaces
    - Click **Apply**
- Firewall > Rules > LAN
  - Modify the Default allow LAN to any rule
    - Change source to **Any**
    - Enable logging
    - Description: allow all traffic on bridge
    - This change is to allow multicast, broadcasts and DHCP to work
    - Click **Save**
  - Disable the IPv6 rule
    - Edit
    - Check Disable this rule
    - Click **Save**
  - Click **Apply changes**

# Update Firmware and Enable Guest Tools
- Add gateway to Internet
  - System > Gateways > Configuration
  - Add
    - Name: **Lab_gateway**
    - Interface: **LAN**
    - IP Address: *your Lab gateway IP (the router)*
    - Description: **Internet gateway**
    - Click **Save**
    - Click **Apply**
- Add gateway to LAN
  - Interfaces > LAN
  - IPv4 gateway rules: **Lab_gateway**
  - Click **Save**
  - Click **Apply changes**
- Update Firmware
  - System > Firmware > Status > Check for Updates
  - NOTE this will fail the first time; it's known bug
  - Check for Updates again, read the long message, and click Close
  - Scroll down to the end, and click **Update**
  - Click **OK** to accept the reboot
- Enable Guest Tools
  - Log back in
  - System > Firmware > Plugins
  - Check Show community plugins
  - os-xen - click "+" to install
  - Power > Reboot > Yes

# Create a Desktop VM
- New > VM
- Pool **xcp-ng-lab1`
- Template: choose from **win10-lan-ready**, **win11-lan-ready** or **ubuntu-desktop-lan**
- Name: **l2test**
- Description: testing L2 firewall
- Make sure network is **L2net**
- If you choose Window 11 template, remember to use Advanced settings to disable adding a VTPM
- Click **Create**

# Testing
- At this point network connectivity is working (ping, nslookup), Internet
- Create a rule for the LAN interface to block certain traffic (enable loggingfor the rule)
  - Place the rule above the allow rule, save and apply changes
- View the firewall logs
  - Firewall > Log Files > Live View
  - Repeat your tests of the Internet connection including the traffic that should be blocked

IMPORTANT with the L2 firewall, it's best to use DHCP reservations or static IP addresses so you can create effective firewall rules
