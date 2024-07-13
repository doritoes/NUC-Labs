# Install OPNsense firewall
OPNsense community edition is selected for the pentesting lab, mainly for its proven ability to secure handle all Internet traffic via ToR.

References:
- https://www.youtube.com/watch?v=KecQ4AZ-RBo
- https://docs.xcp-ng.org/guides/pfsense/
- https://xcp-ng.org/docs/networking.html#vlans

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
    - Under the list of PIFs (physical interfaes), find the new Pentesting interface, click **Status** to  disconnect it from your the eth0 interface

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
  - Description: *opnsense pentesting lab firewall*
  - CPU: **4 vCPU**
  - RAM: **2GB**
  - Topology: *Default behavior*
  - Install: ISO/DVD: Select the OPNsense ISO image you uploaded
  - First Interfaces:
    - Network: from the dropdown select the **pool-wide host network (eth0)**
  - Second Interface: Click **Add interface**
    - Network: from the dropdown select the **Pentesting** network you created earlier
  - Disks: Click **Add disk**
    - Add **20GB** disk
  - Click **Show advanced settings**
    - Check **Auto power on**
  - Click **Create**
- The details for the new VyOS VM are now displayed
- Click the **Network** tab
  - Next to each interface is a small settings icon with a blue background
  - For every interface click the icon then <ins>disable TX checksumming</ins>
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
  - Accept erasing the disk
- Accept recommended swap partition if prompted
- Select a root password when prompted
- Select Complete Install
- Eject the ISO (click the icon on Console tab)
- Wait for the system to boot
- Log in as `root` with the selected password (default password is `opnsense`)
- Option 1) **Assign interfaces**
  - LAGGs: **No**
  - VLANs: **No**
  - WAN interface: **xn0**
  - LAN interface: **xn1**
  - Optional (OPT1): just press enter
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
    - Restore web GUI access defaults: No
  - Configure **WAN**
    - DHCP: **Yes**
    - IPv6: No, and press enter to confirm no IPv6 address
    - Change web GUI protocol to HTTP: **No**
    - Generate a new slef-signed web GUI certificate: **No**
    - Restore web GUI access defaults: **No**
- Create a VM on the Pentesting network
  - Unbuntu Desktop or Windows 10 is perfect
  - From the left menu click **New** > **VM**
  - Select the pool **xcp-ng-lab1**
  - Select the **win10-lan-ready** or **ubuntu-desktop-lab** template
  - Name: **pentest-workstation*
  - <ins>Change</ins> the Interface to **Pentesting**
  - Click **Create**
- Initial firewall configuration
  - From VM's browser, log in to firewall https://192.168.101.254
    - User `root` and password you selected
  - Follow the Wizard
    - General information
      - Hostname: *pentestfw**
      - Domain: **xcpng.lab**
      - Primary DNS Server: **8.8.8.8** (we want unfilted DNS for this network)
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
      - Review and click *Next**
    - Set Root Password
      - Click **Next** to keep the existing password
    - Click **Reload**
  - Update OPNsense
    - Click **System** > **Firmware** > **Status**
    - Click **Check for Updates**
    - Read and accept the information provided
    - Scroll to the bottom of the Updates tab and click **Update**
    - Wait for updates and the reboot
    - Log back in and check if there are any more updates
  - Install Xen guest utilities
    - Sytem > Firmware > Plugins
      - os-xen - click "+" to install
      - Reboot (Power > Reboot?)
    - In XO, look at the opnsense VM general tab; management agent is now detected
- Configure Firewall Rules
  - The default WAN settings will prevent the Penstesting network from accessing anything but the Internet
    - Explanation: By default RFC1918 networks (including 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16)

# Configure TOR
References:
- https://docs.opnsense.org/manual/how-tos/tor.html
- https://www.youtube.com/watch?v=4K2YuWp2GB4
- https://cybernomad.online/dark-web-building-a-tor-gateway-7a7dfa45884f

Steps:
- From VM's browser, check the public IP address without TOR
- Log in to firewall https://192.168.101.254
- System > Firmware > Plugins
  - os-tor - click "+" to install
- Refresh the page
- Click **Services** > **Tor** > **Configuration**
- Click Configuration
  - General Tab
    - Enable: Yes
    - Listen Interfaces: LAN
    - Enable Advanced Mode
      - Check Enable Transparent Proxy
      - Confirm SOCKS port number: 9050
      - Confirm Control Port: 9051
      - Confirm Transparent port: 9040
      - Confirm Transparent DNS port: 9053
  - Click **Save**
- **Firewall** > **Rules** > **LAN**
  - Add top rule Allow LAN net to This Firewall IP for TCP/IP DNS
  - Add following rule DENY to ANY for TCP/IP DNS
  - Click Apply Changes
- Firewall > NAT > Port Forward
  - Add rule
    - Interface: LAN
    - TCP/IP Version: IPv4
    - Protocol: TCP (TOR rejects UDP packets except for DNS requests)
    - Source: default usually sufficient; everything on the LAN interface
    - Destination: ANY
    - Destination Port: ANY
    - Redirect Target IP: Single Host or Network: 127.0.0.1
    - Redirect Target Port: 9040 (this is the Transparent TOR port)
    - Click Apply Changes
- Using your browser connect to https://check.torproject.org
  - You should see "Congratulations. This browser is configured to use Tor."

# Test TOR access
- Try updating your VM's OS
- Test Folding at Home (https://foldingathome.org/start-folding/)
  - Windows is straightforward
  - Ubuntu desktop
    - download the .deb file
    - open the .deb file and select Software Install
    - Click Install and enter your password
    - Point your browser to http://127.0.0.1:7396
    - This will redirect you to the centralized configuration sytem
    - Configure and start Folding!
    - Remember the VM has to be halted to add more vCPUs
    - WARNING this is the point in my Lab where the host started powering itself down
      - very strange, the host NUC just powered off
      - powering back on, with only the XO server, VyOS router, and OPNsense firewall auto starting, it powers itself back off (the VM I just edited was not running; it was in Halted state)
