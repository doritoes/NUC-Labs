# Install XCP-ng

# Create Account on xen-orchestra.com
An account is required to register your Xen Orchestra virtual Appliance (XOA), which you will use to manage the system
- this is a "Vates" community account, as vates.tech manages the XCP-ng product
- https://xen-orchestra.com/#!/signup

# Create Bootable Installation USB
- Download ISO from https://docs.xcp-ng.org/installation/install-xcp-ng/
- Create Bootable USB using [Balena Etcher](https://etcher.balena.io/)

# Intial Intallation
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
  - xen-orchestra.com username:
  - xen-orchestra.com username:
- Set the XOA machine password
  - Login: xoa (default)
  - Password: labboss
- Click DEPLOY
- Wait as the XOA image is downloaded and the VM deployed
