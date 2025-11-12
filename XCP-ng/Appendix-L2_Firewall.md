# Appendix - L2 Firewall
OPNsense supports a "transparent filtering bridge", which is elsewhere called a Layer 2 (L2) firewall. A Layer 2 firewall does not perform routing nor NAT. It is deployed between two devices on the same LAN, filtering traffic without creating different subnets.

For example, you want to isolate a device while keeping it on the same LAN.

💣However, attempts to reproduce the tutorial were not immediately successful.
- Need to try a new approach based on https://docs.opnsense.org/manual/how-tos/lan_bridge.html

References:
- https://docs.opnsense.org/manual/how-tos/transparent_bridge.html
- https://www.zenarmor.com/docs/network-security-tutorials/how-to-configure-transparent-filtering-bridge-on-opnsense

See also: https://docs.opnsense.org/manual/how-tos/lan_bridge.html

Warnings:
- L2 firewall not compatible with traffic shaping
- Most L2 firewalls cannot do IPS; needs confirmation for OPNsense

Overview:
- Start from a default installation on a virtual device with 2 interfaces
- Disable NAT
- Enable setting to allow filtering on bridge interfaces
- Create a Bridge interface and assign a management IP address to it
- Disable DHCP server on LAN
- Add Allow rules
- Disable Default Anti-Lockout Rule
- Set LAN and WAN interfaces to type "none"
- Apply Changes

# Modify the Network
🌱 do we need to add something to XCP-ng here?
- Add a private network for the secured host(s)
  - Home > Hosts > xcp-ng-lab1
  - Network > Manager
  - Add a newwork
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
  - RAM: **4GB** (recommended is 8GB, but for this lab we are using 4GB, warnings appear for less than 3GB)
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the OPNsense ISO image you uploaded*
  - First Interfaces:
    - Network: from the dropdown select the **pool-wide host network (eth0)**
    - Management interface
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
- Select a **Root Password** when prompted
- Select **Complete Install**
- Select **Reboot now**
- Eject the ISO once the reboot starts (click the eject icon on Console tab)
- Wait for the system to boot

# Configure OPNsense
- Log in to Console user `root` with the password you selected
- 1) Assign interfaces
  - LAGGs? **No**
  - VLANs? **No**
  - WAN interface name: **none**
  - LAN interface name: **xn0**
  - Optional interface:
  - OPT1 interface name: **xn1**
  - OPT2 interface name: **xn2**
  - Optional interface: *just press enter*
  - Proceed: **Yes**
- 2) Set interface IP addresses
  - LAN
    - Configure IP via DHCP? **No**
    - LAN IPv4 Address: **192.168.1.150** (an IP address on your Lab network)
    - Mask bits: **24** (to match your Lab network)
    - Upstream gateway: *press Enter to accept no gateway*
    - IPv6 address: **No**, **No**, and **None** (press Enter)
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
  - Click **Next**
  - General Information tab
    - Hostname: l2firewall
    - Domain: xcpng.lab
    - Optionally set Timezone
    - DMZ: 9.9.9.9, 1.1.1.1
    - Uncheck Override DNS
    - Uncheck Enable Resolver
    - Click **Next**
  - Network [WAN] tab
    - Type: DHCP (since there is no WAN interface, this is the easiest option)
    - Oddly it still asks for an IP address(!); in Lab used 1.1.1.1/32
    - Don't block RFC1918 private networks or bogon networks
    - Click **Next**
  - Network [LAB] tab
    - Uncheck Configure DHCP server
    - Click **Next**
  - Set initial password tab
    - Click **Next** to leave password the same
  - Click **Apply** to finish the wizard
- Create the bridge
  - Interfaces > Devices > Bridge
  - ADD a new bridge
  - Select OPT1 and OPT2
  - Optionally add a description
  - The bridge needs to be enabled
  - Click **Save**
  - Click **Apply**
- The OPT1 and OPT2 interfaces should NOT have any IP address configuration
  - they should be enabled, that's it
- Interfaces > Assignments
  - Change LAN to bridge0 (Bridge)
  - Delete the WAN interface
- System Tunables
  - System > Settings > Tunables
    - net.link.bridge.pfil_member = 0
      - Set to 0 to disable filtering on the incoming and outgoing member interfaces
    - net.link.bridge.pfil_bridge = 1
      - Set to 1 to enable filtering on the bridge interfaces
    - Save
    - Apply
- Firewall > Rules > LAN
  - Modify the Default allow LAN to any rule
    - Change source to Any
    - Enable logging
    - This change is to allow broadcasts and DHCP to work
  - Disable the IPv6 rule

# Create a Desktop VM
- New > VM
- Pool **xcp-ng-lab1`
- Template: choose either **Win10-lan-ready** or **Ubuntu-desktop-lan**
- Name: **l2test**
- Decription: testing L2 firewall
- Make sure network is **L2net**
- Click **Create**

# Testing
- At this point network connectivity is working (ping, nsloookup), Internet
- Create a rule for the LAN interface to block certain traffic (enable loggingfor the rule)
  - Place the rule above the allow rule, save and apply changes
- View the firewall logs
  - Firewall > Log Files > Live View
  - Repeat your tests of the Internet connection including the traffic that should be blocked

IMPORTANT with the L2 firewall, it's best to use DHCP reservations or static IP addresses so you can create effective firewall rules
