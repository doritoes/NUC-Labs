# Appendix - L2 Firewall
OPNsense supports a "transparent bridge", which is elsewhere called a Layer 2 (L2) firewall. A Layer 2 firewall does not perform routing nor NAT. It is deployed betweek two devices on the same LAN, filtering traffic without creating different subnets.

However, attempts to reproduce the tutorial were not immediately successful.

Reference: https://docs.opnsense.org/manual/how-tos/transparent_bridge.html

Warnings:
- L2 firewall not compatible with traffic shaping
- Most L2 firewalls cannot do IPS; this bears confirmation

Overview:
- Start from a default installation on a virtual device with 2 interfaces
- Disable NAT
- Enable setting to allow filtering on bridge interfcaces
- Create a Bridge interface and assign a management IP address to it
- Disable DHCP server on LAN
- Add Allow rules
- Disable Default Anti-Lockout Rule
- Set LAN and WAN interfaces to type "none"
- Apply Changes

# Create OPNSense VM
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **opnsenseL2**
  - Description: *opnsense Layer 2 firewall*
  - CPU: **4 vCPU**
  - RAM: **2GB**
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the OPNsense ISO image you uploaded*
  - First Interfaces:
    - Network: from the dropdown select the **pool-wide host network (eth0)**
  - Second Interface: Click **Add interface**
    - Network: from the dropdown select the **Inside**
  - Disks: Click **Add disk**
    - Add **20GB** disk
  - Click **Show advanced settings**
    - Check **Auto power on**
  - Click **Create**
- The details for the new VyOS VM are now displayed
- Click the **Network** tab
  - Next to each interface is a small settings icon with a blue background
  - For every interface click the gear icon then <ins>disable TX checksumming</ins>
- Click **Console** tab and watch as the system boots
- Click the **Network** tab
  - Next to each interface there is a gear icon
  - Click each gear icon and <ins>disable TX checksumming</ins>

# Install OPNsense
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
- Select Complete Install
- Eject the ISO (click the icon on Console tab)
- Wait for the system to boot
- The firewall is now configured with default settings

# Configure OPNsense LAN DHCP
- Log in to Console user `root` with the password you selected
- 1) Assign interfaces
  - LAGGs? **No**
  - VLANs? **No**
  - WAN interface name: **xn0**
  - LAN interface name: **xn1**
  - Optional interface: *just press enter*
  - Proceed: **Yes**
- 2) Set interface IP addresses
  - LAN
    - Configure IP via DHCP? **No**
    - LAN IPv4 Address: **192.168.1.1**
    - Mask bits: **24**
    - Upstream gateway: *press Enter to accept no gateway*
    - IPv6 address: **No**, **No**, and **None** (press Enter)
    - Enable DHCP server on LAN: **Yes**
    - Start of range: **192.168.1.10**
    - End of range: **192.168.1.250**
    - Change to HTTP: **No**
    - Generate new self-signed web GUI certificate? **No**
    - Restore web GUI defaults? **No**

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
- Set LAN and WAN interface type to 'None'
  - Interfaces > [LAN]
    - IPv4 Configuration Type: **None**
    - Click **Save**
  - Interfaces > WAN
    - IPv4 Configuration Type: **None**
    - Click **Save**
- Apply the Changes
# Testing
In lab testing this did NOT work. DHCP does not work to pass through the IP address from outside the L2 firewall.

Concerns:
- The documentation has conflicting information: a second author modified the tutorial to dispute some of the settings
- The documenation has the user set the PC to the subnet that the managment IP is on
  - this allows managment of the firewall, but did allow access to the Internet
- Setting the IP address statically on the VM to match what the DHCP server would have given me did not work either. Traffic over the bridge didn't work.



- Point your browser to the IP address you configured for management
  - Example: https://192.168.200.1
- Tune the firewall rules on [bridge]
  - Now you can start testing and add rules to block traffic
