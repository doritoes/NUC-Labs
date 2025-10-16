# Install XCP-ng
In this Lab we will use XO to manage the environment. Please be aware that XO Lite exists in beta and is coming in the near future.

References: https://www.youtube.com/watch?v=fuS7tSOxcSo

We will start with a the XOA virtual appliances, then build our own XO installation to replace it

# Create Account on xen-orchestra.com
An account is required to register your Xen Orchestra virtual Appliance (XOA), which you will initially use to manage the system
- this is a "Vates" community account, as vates.tech manages the XCP-ng product
- https://xen-orchestra.com/#!/signup

# Create Bootable Installation USB
- Download ISO from https://docs.xcp-ng.org/installation/install-xcp-ng/
- Create Bootable USB using [Balena Etcher](https://etcher.balena.io/)

# Initial Installation
- Boot from USB (UEFI mode) by pressing F10 on the NUC and selecting the UEFI USB stick image
- Wait at the boot menu to press enter to start `install`
- Select your keyboard
- Select OK to continue
- Accept the EULA
- Accept the storage
  - LVM is block storage that is faster, but is "thick provisioned"
  - EXT is file storage that is slower, but is "thin provisioned",  means you can "overallocate" storage if you have a small storage drive
  - The default is now EXT
- Type of source: Local Media
- Verification: Verify media or don't, it's your choice
- Select and enter the root password (6+ characters)
- Choose IPv4 (only) for this Lab
- Use DHCP wherever possible - use your router to reserve a fixed IP address (much more flexible than a static IP address)
- Select a hostname (e.g., xcp-ng-lab1)
- Use DHCP for DNS
- Select region and city
- Set NTP to pool.ntp.org (if your router supports NTP options, set can configure the router and XCP-ng to share that information)
- Select **Install XCP-ng**
- Remove the USB stick when prompted and press Enter to reboot
- Wait as the system reboots

Notes:
- Tested on a NUC 14 with lots of storage
  - nvme 4TB
  - nvme 2TB
  - SATA 4TB
  - thunderbolt nvme 4TB
- Selecting all the drives during installation caused the system to come up with NO local storage
- Selecting just the nvme0 4TB installed as expected
  - To use the additional drxives
    - SATA Drive
      - **New** > **Storage**
      - Host: **xcpng-lab1**
      - Name: **SATA Drive** (customize as needed)
      - Description: **Internal SATA 4TB drive**
      - Storage type: **VDI SR** > **ext (local)**
      - Device: **/dev/sata**
      - Click **Create**
    - Internal second nvme 2TB
      - **New** > **Storage**
      - Host: **xcpng-lab1**
      - Name: **Second Internal Drive** (customize as needed)
      - Decription: **Internal nvme 2TB drive**
      - Storage type: **VDI SR** > **ext (local)**
      - Device: **/dev/nvme1n1**
      - Click **Create**
- External Thunderbolt drive challenges
  - Attempts to similarly mount nvme0n1 for the external Thunderbolt drive errored out
  - Removed the external Thunderbolt drive, reinstalled, then after configured added the Thunderbolt drive; it now appeared as /dev/sdb and was able to be used
