# Install VyOS router
How to create a router to our backend "LAN"

# Configure Networking
- Log in to proxmox (e.g., https://192.168.99.205:8006)
- From the left menu navigate to **Datacenter** > **proxmox-lab**
- Click on the host (proxmox-lab) to reveal the host settings
- Click **System** > **Network**
- Click **Create** > **Linux Bridge**
  - Name: **vmbr1**
  - Autostart: **Checked**
  - Click **Create**
- Click **Apply Configuration** and the new bridge will start (is a button next to Create and Revert)

Here is list of the virtual bridges we will use in this lab:
- vmbr0 - default bridge to the physical network interface
- vmbr1 - "Inside" network
- vmbr2 - "Pentesting" network

# Download the ISO
1. Go to https://vyos.io
2. Click Rolling Release
    - the free version is limited to the Rolling Release
4. Download the most recent image

# Upload the ISO
If you linked storage to a file share, copy the file there.

Or, if you created local storage, upload the ISO there.
- From the left menu expand **Datacenter** > **proxmox-lab**
- Click **local (proxmox-lab)**
- Click **ISO Images**
- Click **Upload** and follow the prompts

# Create VyOS VM
- From the top ribbon click **Create VM**
  - General tab
    - Node: Auto selects **proxmox-lab**
    - VM ID: automatically populated; each resource requires a unique ID
    - Name: **vyos**
  - OS tab (clicking Next takes you to the next tab)
    - Use CD/DVD disk image file (iso)
      - Storage: *select one of the storage points you configured, or local*
      - ISO image: *select the image you uploaded from the dropdown*
    - Guest OS:
      - Type: Linux (VyOS is based on Debian)
      - Version: 6.x - 2.6 Kernel
  - System tab
    - In December 2024, VyOS stopped including VM agents
      - To confirm, `apt list --installed | grep queme` (or is it queme)
      - Leave **Qemu Agent** unchecked unless you roll your own ISO build with it included
  - Disks tab
    - Disk size: **8GB**
    - Check **Discard** because our host is using SSD
  - CPU tab
    - Sockets: **1**
    - Cores: **2**
    - Type: Leave at the default (my Lab it's x86-64-v2-AES)
  - Memory tab
    - RAM: **1024**MiB = 1GiB
  - Network tab
    - Bridge: vmbr0
    - VLAN Tag: no VLAN
    - Model: VirtIO (best performance)
    - MAC address: leave at auto
    - Firewall: **Uncheck** (default is checked)
  - Confirm tab
  - <ins>Don't check</ins> **Start after created**
  - Click **Finish**
- Click on the VM **vyos** (ID 100) in the left pane
  - Click **Hardware**
  - Click **Add** > **Network Device**
    - Bridge: **vmbr1**
    - Firewall: **Uncheck**
    - Click **Add**
  - Edit Network device (net0) to uncheck Firewall
- Click **Start**
- Click **Console** (in the main pane menu, to the right of Start and Shutdown)
  - A new window will be opened for the console, using noVNC
  - If the VM is not started, proxmox will help you start it
  - Did you get a kernel panic in the VyOS VM? Try 2 vCPUs not 1
- Login as `vyos`/`vyos`
- `install image`
- Allow installation to continue with default values
  - Enter the new password for the `vyos` user
    - Fun fact, it allows you to set the password to `vyos`
- When done reboot: `reboot`
- Eject the VyOS ISO
  - Click on the VM vyos > **Hardware** > **CD/DVD Drive**
  - **Edit** and select **Do not use any media**
- Log back in with your updated password
- Configure your router's "Internet" connection (your Lab network via the host's ethernet interface)
  - `configure`
  - `set interfaces ethernet eth0 address dhcp`
  - `set service ssh`
  - `commit`
  - `save`
  - `exit`
- View your router's IP address
  - `show interfaces ethernet eth0 brief`
- You can now configure your router from another device in your Lab; SSH to this IP address

# Configure Router
IMPORTANT note the version is VyOS 1.5-rolling-2024xxxxxxxx, and the syntax has changed from previous versions you may be familiar with.
- ssh to the router and login as user `vyos` with the password you selected
- enter the configuration below
```
configure
set interfaces ethernet eth0 description 'OUTSIDE'
set interfaces ethernet eth1 address '192.168.100.254/24'
set interfaces ethernet eth1 description 'INSIDE'
set nat source rule 100 outbound-interface name 'eth0'
set nat source rule 100 source address '192.168.100.0/24'
set nat source rule 100 translation address 'masquerade'
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
  - if it's not working, `route` and see if the default route is missing; reboot and try again

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
set service dhcp-server shared-network-name vyoslab subnet 192.168.100.0/24 range 0 stop 192.168.100.250
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
