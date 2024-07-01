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
  - Under the list of PIFs (physical interfaces), for the new Insider interface, click Status and change to Disconnected
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
2. Click Rolling Rrelease
3. Download vyos-rolling-latest.iso

# Create VM
continue writing here
