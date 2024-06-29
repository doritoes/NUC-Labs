# Install XCP-ng
In this Lab we will use XO to manage the environment. Please be aware that XO Lite exists in beta and is coming in the near future.

References: https://www.youtube.com/watch?v=fuS7tSOxcSo

We will start with a the XOA virtual appliances, then build our own XO installation to replace it

# Create Account on xen-orchestra.com
An account is required to register your Xen Orchestra virtual Appliance (XOA), which you will use to manage the system
- this is a "Vates" community account, as vates.tech manages the XCP-ng product
- https://xen-orchestra.com/#!/signup

# Create Bootable Installation USB
- Download ISO from https://docs.xcp-ng.org/installation/install-xcp-ng/
- Create Bootable USB using [Balena Etcher](https://etcher.balena.io/)

# Intial Installation
- Boot from USB (UEFI mode) by pressing F10 on the NUC and selecting the UEFI USB stick image
- Wait at the boot menu to press enter to start `install`
- Select your keyboard
- Select OK to continue
- Accept the EULA
- Access the storage
- Type of source: Local Media
- Verification: Verify media or don't, it's your choice
- Select and enter the root password (6+ characters)
- Use DHCP wherever possible - use your router to reserve a fixed IP address (much more flexible than a static IP address)
- Select a hostname (e.g., xcp-ng-lab1)
- Use DHCP for DNS
- Select region and city
- Set NTP to pool.ntp.org (if your router supports NTP options, set can configure the router and XCP-np to share that information)
- Install Supplemental Packs: NO
- Remove the USB stick when prompted

# Intial Configuration
Configure Xen Orchestra (XO) virtual Appliance (XOA) to manage the system
- Point your browser to the IP address of the NUC
  - Example: https://192.168.99.100
- Under management tools, click Quick Deploy under Xen Orchestra
- Login with the root password you set earlier
- Leave the network settings at their defaults to use DHCP (later set up a DHCP reservation)
- Click NEXT
- Create Admin account on your XOA
  - Username: admin
  - Password: labboss
- Register your XOA
  - xen-orchestra.com username: use the value you used when registering
  - xen-orchestra.com username: use the value you used when registering
- Set the XOA machine password
  - Login: xoa (default)
  - Password: labboss
- Click DEPLOY
- Wait as the XOA image is downloaded and the VM deployed

IMPORTANT Another IP address is used for XO, and your broswer is automatically redirected to the log in page

IMPORTANT Another method to install is using the Web UI method: https://vates.tech/deploy

# Configure Xex Orchestra
- Log in as username `admin` and password `labboss`
- Apply Updates
  - Click XOA from the left menu then click Updates
  - If an upgrade is available, click Upgrade and wait for the upgrade to complete and for XOA to reconnect
    - Click Refresh to connect as needed
    - In my testing I had to upgrade two times

# Deploy Ubuntu Server to Replace XOA


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
