# Install VyOS router
How to create a router to our backend "LAN"

# Configure Networking
- Log in to XO
- From the left menu click **Home** > **Hosts**
- Click on the host you configured (i.e., xcp-ng-lab1)
- Click the **Network** tab
- Under Private networks click **Manage**
  - Click **Add a Network**
    - Interface: **eth0** (pool-wide network)
    - Name: **Inside**
    - Description: **Inside Lab Network**
    - MTU: leave blank (default 1500)
    - VLAN: **100**
    - NBD: **No NBD Connection** (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
    - Click **Create network**
- Refresh the page or renavigate to the host's Network tab
- On the PIF for the Inside network, click on the word "Connected" to change it to Disconnected

NOTE in this lab we will use the following VLAN numbers for "internal" networks, not to be trunked on the host's uplink
- 100 = inside LAN
- 200 = pentesting network

# Download the ISO
1. Go to https://vyos.io
2. Click Rolling Release
  - the free version is limited to the Rolling Release
4. Download the most recent image

# Upload the ISO
If you linked storage to a file share, copy the file there.

Or, if you created local storage, upload the ISO there.
- From the left menu Click Import > Disk
- Select the SR from the dropdown, LOCAL-ISO
- Drag and drop the vyos ISO file in the box
- Click Import

# Create VyOS VM
- From the left menu click New > VM
  - Select the pool **xcp-ng-lab1**
  - Template: **Other install media**
  - Name: **VyOS**
  - Description: **VyOS router**
  - CPU: **2 vCPU**
  - RAM: **1GB**
  - Topology: **Default behavior**
  - Install: ISO/DVD: *Select the vyos ISO image you uploaded earlier*
  - Interfaces: Click **Add interface** to add a second interface
    - Network: from the dropdown select the **Inside** network you created earlier
  - Disks: Click Add disk
    - **8GB**
  - Click **Show advanced settings**
    - Check **Auto power on**
  - Click **Create**
- The details for the new VyOS VM are now displayed
  - Did you get a kernel panic in the VyOS VM? Try 2 vCPUs not 1
- Click Console to access the console command line
- Login as `vyos`/`vyos`
- `install image`
- Allow installation to continue with default values
  - Enter the new password for the `vyos` user
    - Fun fact, it allows you to set the password to `vyos`
- When done reboot: `reboot`
- Eject the VyOS iso
- Log back in with your updated password
- Configure your router's "Internet" connection (to your Lab network via the host's ethernet interface)
  - `configure`
  - `set interfaces ethernet eth0 address dhcp`
  - `set service ssh`
  - `commit`
  - `save`
  - `exit`
- View your router's IP address
  - `show interfaces ethernet eth0 brief`
- You can now configure your router from another device in your Lab using SSH to this IP address

# Configure Router
IMPORTANT note the version is VyOS 1.5-rolling-2024xxxxxxxx, and the syntax has changed from previous versions you may be familiar with.
- ssh to the router and login as user `vyos` and the password you selected
- enter the configuration below
```
configure
set interfaces ethernet eth0 description 'OUTSIDE'
set interfaces ethernet eth1 address '192.168.100.254/24'
set interfaces ethernet eth1 description 'INSIDE'
set nat source rule 100 outbound-interface name 'eth0'
set nat source rule 100 source address '192.168.100.0/24'
set nat srouce rule 100 translation address 'masquerade'
set system host-name 'router'
set system name-server '9.9.9.9'
set system time-zone US/Eastern
commit
save
exit
```
- Test internet connectivity
  - by pinging an IP address: `ping 8.8.8.8`
  - nslookup a DNS name: `nslookup microsoft.com`
  - if it's not working, `route` and see if the default route is missing; reboot and try again.

NOTE feel free to customize/change the inside LAB subnet, the DNS server IP, time zone, etc.

## Configure DHCP on the inside/LAN interface
We use DHCP for this Lab. You can skip this if you plan on using all static IP addresses.

Note that IP addresses .1 to .19 and .241 to .253 are available to use for static IP addresses.

```
configure
set service dhcp-server shared-network-name vyoslab authoritative
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 subnet-id 100
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 option default-router 192.168.100.254
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 option name-server 9.9.9.9
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 option domain-name lablocal
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 lease 3600
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 range 0 start 192.168.100.20
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 range 0 stop 192.168.100.240
commit
save
exit
```
Useful commands:
- `show dhcp server leases`
- `clear dhcp-server lease 192.168.100.20`
  - of course, use the correct IP for the lease you want to clear

## Optionally Set up DNS forwarder
VyOS can be set up to be a DNS forwarder, including caching. This allows clients to query the VyOS device for DNS, and it can pass on requests to public DNS servers.

```
configure
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 option name-server 192.168.100.254
set service dns forwarding system
set service dns forwarding listen-address '192.168.100.254'
set service dns forwarding allow-from '192.168.100.0/24'
commit
save
exit
```

# Xen Tools
The VyOS image comes with vyos-xe-guest-utilities. However, it doesn't seem to work anymore.

Here is how to fix it:
- `cd /etc/systemd/system/`
- `sudo chmod +x /etc/systemd/system/xe-guest-utilities.service`
- `sudo sytemctl start xe-guest-utilties`
- `sudo sytemctl enable xe-guest-utilties`

If it's not sticking for you (lose it on reboot) try doing a "configure", "commit", "save", "exit" cycle after making the above changes.

If you want to remove the tools: `sudo apt purge -y vyos-xe-guest-utilities`
