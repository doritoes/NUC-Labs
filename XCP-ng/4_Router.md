# Install VyOS router
How to create a router to our backend "LAN"

# Configure Networking
- Configure networks
  - Click Home from the left menu then click Hosts
  - Click on the host you configured (i.e., xcp-xg-lab1)
  - Click the Network tab
  - Under Private networks click Manage
    - Click Add a Network
      - Interface: eth0
      - Name: Inside
      - Description: Inside Lab Network
      - MTU: leave blank (default 1500)
      - VLAN: 100
      - NBD: No NBD Connection (NBD = network block device;  XenServer acts as a network block device server and makes VDI
      - Click snapshots available over NBD connections)
  - Under the list of PIFs (physical interfaces), for the new Inside interface, click Status and change to Disconnected
  - Click Add a Network
      - Interface: eth0
      - Name: Pentesting
      - Description: Pentesting Network
      - MTU: leave blank (default 1500)
      - VLAN: 200
      - NBD: No NBD Connection (NBD = network block device;  XenServer acts as a network block device server and makes VDI snapshots available over NBD connections)
  - Under the list of PIFs (physical interfaces), for the new Pentesting interface, click Status and change to Disconnected

# Download the ISO
1. Go to https://vyos.io
2. Click Rolling Release
3. Download the most recent image

# Upload the ISO
If you linked storage to a file share, copy the file there.

Or, if you created local storage, upload the ISO there.
- From the left menu Click Import > Disk
- Select the SR from the dropdown, LOCAL-ISO
- Drag and drop the vyos ISO file in the box
- Click Import

# Create VyOS VM
- From the left menu click New > VM
  - Select the pool
  - Template: Other install media
  - Name: VyOS
  - Description: VyOS router
  - CPU: 2 vCPU
  - RAM: 1GB
  - Topology: Default behavior
  - Install: ISO/DVD: Select the vyos ISO image
  - Interfaces: Click Add interface
    - Network: from the dropdown select the Inside network you created earlier
  - Disks: Click Add disk
    - 8GB
  - Click Show advanced settings
    - Check Auto power on
  - Click Create
- The details for the new VyOS VM are now displayed
  - Did you get a kernel panic? Try 2 vCPUs not 1
- Click Console
- Login as `vyos`/`vyos`
- `install image`
- Allow installation to continue with default values
  - Enter the new password for the `vyos` user
    - Fun fact, it allows you to set the password to `vyos`
- When done reboot: `reboot`
- Log back in with your updated password
- Configure your router's "Internet" connection (to your Lab network via the host's Ethernet interface)
  - configure
  - set interfaces ethernet eth0 address dhcp
  - set service ssh
  - commit
  - save
  - exit
- View your router's IP address
  - `show interfaces ethernet eth0 brief`
- You can now configure your router from another device in your Lab using SSH to this IP address

# Configure Router
IMPORTANT note the version is VyOS 1.5-rolling-2024xxxxxxxx, and the syntax has changed moving to this version.
- ssh to your router and login as user `vyos` and the password you selected
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
- Test internet connetivity
  - by pinging an IP address: `ping 8.8.8.8`
  - nslook a DNS name: `nslookup microsoft.com`
NOTE feel free to customize/change inside LAB subnet, the DNS server IP, time zone, etc.

## Optionally Configure DHCP on the inside/LAN interface
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
