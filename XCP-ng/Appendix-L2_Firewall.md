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
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **opnsenseL2**
  - Description: *opnsense Layer 2 firewall*
  - CPU: **4 vCPU**
  - RAM: **4GB** (recommended is 8GB, but for this lab we are using 4GB, warnings appear for less than 3GB)
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the OPNsense ISO image you uploaded*
  - First Interfaces:
    - Network: from the dropdown select the **pool-wide host network (eth0)**
    - Management interface
  - 🌱 Revaluating the L2 bridge requirements, set up OPNsense with single LAN, then add extra NICs during installation
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
- System: Configuration: Wizard
  - Log in to the firewall using the IP address you set (i.e., https://192.168.1.150)
  - Next
  - General Information tab
    - Hostname: l2firewall
    - Domain: xcpng.lab
    - Optionally set Timezone
    - DMZ: 9.9.9.9, 1.1.1.1
    - Uncheck Override DNS
    - Uncheck Enable Resolver
    - Click Next
  - Network [WAN] tab
    - Type: DHCP (since there is no WAN interface, this is the easiest option)
    - Oddly it still asks for an IP address(!); in Lab used 1.1.1.1/32
    - Click Next
  - Network [LAB] tab
    - Uncheck Configure DHCP server
    - Click Next
  - Set initial password tab
    - Click Next to leave password the same
  - Click Apply
- Create the bridge
  - Interfaces > Devices > Bridge
  - ADD a new bridge
  - Select OPT1 and OPT2
  - Optionally add a descriptiohn
  - Click Save
- The OPT1 and OPT2 interfaces should NOT have any IP address configuration
  - they should be enabled, that's it
- Interfaces > Assignments
  - Change LAN to bridge0 (Bridge)
  - Swap LAN cable from LAN to one of the NICs added to the bridge, wait for the interfaces comes back up (refresh web page)
  - Reassign the original LAN interfaces to ibg0, or whether the physical is; add new interface and select it
- Configure the Bridge
  - Interfaces > Devices > Bridge
  - Add the newly created interface to the bridge
  - (if using IPv6, check Enable link-local address)
  - Remember the new interface needs to be enabled
- System Tunables
  - System > Settings > Tunables
    - net.link.bridge.pfil_member = 0
      - Set to 0 to disable filtering on the incoming and outgoing member interfaces
    - net.link.bridge.pfil_bridge = 1
      - Set to 1 to enable filtering on the bridge interfaces
    - Save
    - Apply
- Set static IP on the Windows test machine on the L2net network
- At this point network connectivity is working (ping, nsloookup), Internet
- BUT the firewall isn't filtering the traffic
- Setting the Windows test machine to DHCP breaks everything
- Confirm interface assignments
  - Interfaces > Assignments
  - LAN bridge0 (L2 bridge)
  - OPT1 xn1 (mac)
  - OPT2 xn2 (mac)
    - WAN xn0 (mac)
- Power > Reboot, click Yes
- Test again
- Examine firewall rule
  - Firewall > Rules > LAN
  - Note the rue "Default allow LAN to any rule"
  - Edit it, check Log packets that are handled to this rule, click Save
  - Click Apply changes
- View the firewall logs
  - Firewall > Log Files > Live View
  - Repeat your tests of the Internet connection

# Create a Desktop VM
- New > VM
- Pool **xcp-ng-lab1`
- Template: choose either **Win10-lan-ready** or **Ubuntu-desktop-lan**
- Name: **dummy**
- Decription: used for setting up firewall
- Make sure network is **Inside**
- Click **Create**
- The VM will get an IP address on 192.168.1.0/24 (the new firewall)
  - Windows: `ipconfig` and `ipconfig /renew`
  - Unix-like: `ip a` or `ifconfig`
  - if not, make sure you shut down any other devices on **Inside** network that could interfere

# Configure OPNsense
- From VM, log in to https://192.168.1.1
  - User `root` and default password `opnsense` unless you changed it
- Complete the General Setup wizard
  - Hostname: **l2firewall**
  - Domain: **xcpng.lab**
  - Primary DNS server: **8.8.8.8** (want unfiltered DNS here)
  - Secondary DNS: **8.8.4.4**
  - Click **Next**
  - Accept default time server and optionally set Timezone
  - Click **Next**
  - Accept WAN interface settings and click Next
  - Accept LAN interface settings and click Next
  - Set `root` password or leave blank to leave as it was, then click **Next**
  - Click **Reload**
- Update the firmware
  - Click **check for updates**
  - Read and accept the message
  - Scroll down to the bottom and click **Update***
  - Accept the update (and the reboot)
  - Wait patiently as the updates and the reboot are completed
  - Log back in to the web interface
- Configure the filtered bridge interface
  - *See https://docs.opnsense.org/manual/how-tos/transparent_bridge.html*
  - Do <ins>NOT</ins> click apply until the instructions tell you to
    - **Save** your changes after each step
    - Only **Apply** changes after <ins>completely finished</ins>!
- Disable Outbound NAT rule generation
  - **Firewall** > **NAT** > **Outbound**
    - Select **Disable Outbound NAT rule generation**
    - Click **Save** (<ins>do not apply!</ins>
- Change system tuneables
  - System > Settings > Tuneables
    - Edit value of **net.link.bridge.pfil_bridge** to **1**
    - Click **Save**
- Create the bridge
  - **Interfaces** > **Other Types** > **Bridge**
  - Click "+" to add the bridge
    - Member interfaces: **Select LAN and WAN**
    - Description: **Bridge**
    - Click **Save**
- Create management IP address on Bridge
  - **Interfaces** > **Assignnents**
  - Under the new interface **bridge0** add the description **bridge**
  - Click **Add**
  - Select the Bridge from the list and click "+"
  - **Interfaces** > **[bridge]**
    - Check **Enable Interface**
    - Do not check "Block private networks" or "Block bogon networks" in this case (see documentation)
    - IPv4 Configuration Type: **Static IPv4**
    - IPv4 address:
      - Select an IP address you want to use; it does not need to be on any particular network, but to reach it, you will need to be routed through the L2 firewall
      - Example: `192.168.200.1`/`24`
      - Click **Save** (<ins>do not apply</ins>!)
- Disable WAN blocking of private networks and bogons
  - Interfaces > WAN
  - Make certain "block private networks" and "block bogon networks" are not checked
- Disable the DHCP server on LAN
  - Services > ISC DHCPv4 > LAN
  - **Uncheck** Enable DHCP server on the LAN interface
  - Click **Save**
- Add firewall rules to the WAN interface
  - the tutorial says to add Any/any/allow rules on LAN/WAN
  - the tutorial also says these are ignored, and only the bridge rules are parsed
- Add firewall rules to the Bridge interface
  - Firewall > Rules > bridge
  - Click "+" to add a rule
    - Action: **Pass**
    - Interface: **bridge**
    - Direction: **in**
    - TCP/IP version: **IPv4**
    - Protocol: **any**
    - Source: **any**
    - Destination: **any**
    - Log: *enable logging to allow you to see the traffic and decide on how to tune the rules*
    - Description: **default allow rule**
- Set LAN and WAN interface type to `None`
  - Interfaces > [LAN]
    - IPv4 Configuration Type: **None**
    - Click **Save**
  - Interfaces > WAN
    - IPv4 Configuration Type: **None**
    - Click **Save**
- Apply the Changes

# Testing
In lab testing this did NOT work. DHCP does not work to pass through the IP address from outside the L2 firewall.

What works:
- Setting your VM IP address to an IP on the management subnet (i.e. 192.168.200.100) allows you to manage the firewall (but not traverse the bridge)
  - Set VP IP to 192.168.200.100/24 (no gateway will help you here)
  - Example: https://192.168.200.1

Concerns:
- The documentation has conflicting information: a second author modified the tutorial to dispute some of the settings (e.g., "So you can skip this step" in two places)
- The documentation has the user set the PC to the subnet that the management IP is on
  - this allows management of the firewall, but did allow access to the Internet
- Setting the IP address statically on the VM to match what the DHCP server would have given me did not work either. Traffic over the bridge didn't work.
- A related How-To gives clues on how it might work: https://docs.opnsense.org/manual/how-tos/lan_bridge.html

# Next Steps
Once the bridge is working, tune the firewall rules on [bridge] interface
- review logs of allowed traffic
- add rules to block and allow traffic as desired
