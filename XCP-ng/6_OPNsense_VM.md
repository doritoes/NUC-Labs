# Install OPNsense firewall
OPNsense community edition is selected for the pentesting lab, mainly for its proven ability to secure handle all Internet traffic via ToR.

References:
- https://www.youtube.com/watch?v=KecQ4AZ-RBo
- https://docs.xcp-ng.org/guides/pfsense/
- https://xcp-ng.org/docs/networking.html#vlans

# Configure Networking
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
  - Interfaces: Click Add interface
    - Network: from the dropdown select the Inside network you created earlier
  - Interfaces: Click Add interface
    - Network: from the dropdown select the Pentesting network you created earlier
  - Disks: Click Add disk
    - 100GB (if you are thin provisioning like on NFS storage, nothing to worry about; if you are thick provisioning, you can go smaller)
  - Click Show advanced settings
    - Check Auto power on
  - Click Create
- The details for the new VyOS VM are now displayed
- Click Console

disable TX checksum offload on the virtual xen interfaces of the VM
  - advanced settings: for each adapter, disable TX checksumming
 
can we disable the parallel and port? maybe serial port too?

# Configure OPNsense
- Log in as installer/opnsense
- Select the keymapp
- Install (ZFS); it is the best choice for the Lab
  - uses slight more RAM
  - much more stable under power failure or hard reboots
- Accept the disk to install on
- Accept recommended swap partition
- Select Yes to continue
- Select a root password when prompted
- Select Complete Install
- Eject the ISO when prompted
- Wait for the system to boot
- Log in as root with the selected password (default is opnsense)
- set up interfaces LAN on pentesting network
- set up interfaces WAN on the host's network (DHCP)
- Log in using Web browser
  - how in this lab??
- System > Firmware - check for updates
- Install guest utilities
  - Plugins
    - os-xen - click + to install
- Configure DHCP on pentesting network

