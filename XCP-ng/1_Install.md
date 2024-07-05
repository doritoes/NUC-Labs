# Install XCP-ng
In this Lab we will use XO to manage the environment. Please be aware that XO Lite exists in beta and is coming in the near future.

References: https://www.youtube.com/watch?v=fuS7tSOxcSo

We will start with a the XOA virtual appliances, then build our own XO installation to replace it

# Create Account on xen-orchestra.com
An account is required to register your Xen Orchestra virtual Appliance (XOA), which you will initally use to manage the system
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
- Accept the storage
  - LVM is block storage that is faster, but is "thick provisioned"
  - EXT is file storage that is slower, but is "thin provisioned"
  - The default is LVM, but choosing EXT means you can "overallocate" storage if you have a small storage drive
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
- Wait as the system reboots
