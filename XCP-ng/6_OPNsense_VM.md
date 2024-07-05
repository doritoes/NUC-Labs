# Install OPNsense firewall
OPNsense community edition is selected for the pentesting lab, mainly for its proven ability to secure handle all Internet traffic via ToR.

References:
- https://www.youtube.com/watch?v=KecQ4AZ-RBo
- https://docs.xcp-ng.org/guides/pfsense/
- https://xcp-ng.org/docs/networking.html#vlans

# Configure Networking
- Log in to Xen Orchestra (XO)
- Configure networks
  - Click Home from the left menu then click Hosts
  - Click on the host you configured (i.e., xcp-xg-lab1)
  - Click the Network tab
  - Under Private networks click Manage
    - Click Add a Network
      - Interface: eth0
      - Name: Pentesting
      - Description: Inside Pentesting Network
      - MTU: leave blank (default 1500)
      - VLAN: 200
      - NBD: No NBD Connection (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
    - Under the list of PIFs (physical interfaes), for the new Pentesting interface, click Status and change to Disconnected

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
- From the left menu click New > VM
  - Select the pool
  - Template: Other install media
  - Name: opnsense
  - Description: opnsense pentesting lab firewall
  - CPU: 4 vCPU
  - RAM: 2GB
  - Topology: Default behavior
  - Install: ISO/DVD: Select the OPNsense ISO image
  - First Interfaces:
    - Network: from the dropdown select the pool-wide hot network (eth0)
  - Second Interface: Click Add interface
    - Network: from the dropdown select the Pentesting network you created earlier
  - Disks: Click Add disk
    - Add 20GB disk
  - Click Show advanced settings
    - Check Auto power on
  - Click Create
- The details for the new VyOS VM are now displayed
- Click the Network tab
  - Next to each interface is a small settings icon with a blue background
  - For every interface click the icon then disable TX checksumming
- Click Console and watch as the system boots

# Configure OPNsense
- Log in as installer/opnsense
- Select the keymapp
- Install (ZFS); it is the best choice for the Lab
  - stripe - no redundancy (for our Lab this is fine)
  - uses slightly more RAM
  - much more stable under power failure or hard reboots
- Accept the disk to install on
  - You need to check the box (use space bar)
- Accept recommended swap partition
- Select Yes to continue and wait patiently
- Select a root password when prompted
- Select Complete Install
- Eject the ISO
- Wait for the system to boot
- Log in as root with the selected password (default is opnsense)
- Option 1) Assign interfaces
  - LAGGs: No
  - VLANs: No
  - WAN interface: xn0
  - LAN interface: xn1
  - Optional (OPT1): just press enter
  - Confirm
- Option 2) Set interface IP address
  - Configure LAN
    - DHCP: No
    - IPv4 address: 192.168.101.254
    - Subnet mask CIDR: 24
    - Press enter to confirm no upstream gateway on the LAN interface
    - IPv6: No two times, and press enter to confirm no IPv6 address
    - Enable DHCP server on LAN: Yes
    - Client address start: 192.168.101.20
    - Client address end: 192.168.101.250
    - Change web GUI protocol to http: No
    - Generate new self-signed web GUI certificate: Yes
    - Restore web GUI access defaults: No
  - Configure WAN
    - DHCP: Yes
    - IPv6: No, and press enter to confirm no IPv6 address
    - Change web GUI protocol to HTTP: No
    - Generate a new slef-signed web GUI certificate: No
    - Restore web GUI access defaults: No
- Create a VM on the Pentesting network
  - Unbuntu Desktop or Windows 10 is perfect
- Initial firewall configuration
  - From VM's browser, log in to firewall https://192.168.101.254
  - Follow the Wizard
    - General information
      - Hostname: pentestfw
      - Domain: xcpng.lab
      - Primary DNS Server: 8.8.8.8 (we want unfilted DNS for this network)
      - Secondary DNS Server: 8.8.4.4
      - <ins>Uncheck</ins> Override DNS
      - Click Next
    - Time server information
      - Leave the default time server
      - Optionally adjust the Timezone
      - Click Next
    - Configure WAN Interface
      - Review the information, default values are OK
      - Click Next
    - Configure LAN Interface
      - Review and click Next
    - Set Root Password
      - Click Next to keep the existing password
    - Click Reload
  - Update OPNsense
    - Click System > Firmware > Status
    - Click Check for Updates
    - Read and accept the information provided
    - Scroll to the bottom of the Updates tab and click Update
    - Wait for updates and the reboot
    - Log back in and check if there are any more updates
  - Install Xen guest utilities
    - Plugins
      - os-xen - click + to install
      - Reboot (Power > Reboot?
    - In XO, look at the opnsense VM general tab. The management agent is now detected.
- Configure Firewall Rules
  - The default WAN settings will prevent the Penstesting network from accessing anything but the Internet
    - Explanation: By default RFC1928 networks (including 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16)
- Configure TOR for Internet