# Install Proxmox VE
References: https://www.youtube.com/watch?v=fuS7tSOxcSo

Things about Proxmox Virtual Environment
- Based on Debian
- Can install Proxmox in a Debian graphical desktop
- Easier to use Ceph for storage than XCP-ng
- Uses LVMs
- Restful API
- Multi-master for robust handling of failed node/system
- Full virutalization (KVM)

Things about Ceph
- Ceph is an open source software-defined storage solution designed to address the block, file and object storage needs of modern enterprises
- Decouples physical storage hardware using software abstraction layers
- Storage clustering solution; add any number of disks on any number of machines into one big storage cluster
- Ideal for cloud, Openstack, Kubernetes, et.
- Configuration for ceph can include the number of copies of a file (set 2 means cluster will always have 3 copies of all the objects this setting applies to)
- self-managing, meaning that it will automatically try to distribute these copies over 3 physical machines (if possible), onto 3 separate disks; When any disk or machine dies, ceph will immediately use the 2 remaining copies of the affected objects and create a 3rd copy in the cluster.

# Create Bootable Installation USB
- Download ISO from https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso
  - Select the latest version ISO; this Lab tested with Proxmox vE 8.2
- Create Bootable USB using [Balena Etcher](https://etcher.balena.io/)

# Initial Installation
- Insert the installation USB
- Boot from USB (UEFI mode) by powerng on and pressing F10 on the NUC
- Select the UEFI USB stick image
- Select Graphical Installation and follow the Wizard
  - Accept EULA
  - Accept Storage
  - Set Country, Time Zone, and Keyboard
  - Select root password
  - Enter an email address to receive alerts
  - Verify/Set the management interface
    - eno1
    - Hostname with domain: proxymox-lab.prox.lab
    - IP address and network information
    - WARNING this seems to set a static IP address based on the DHCP IP received
  - Accept summary
  - It won't tell you to remove the installation media, but remove it when it goes to reboot
    - if you don't remove it, it will probably boot back to the USB and show the installation GUI
    - remove the USB and press ctrl-alt-delete and the system will reboot
- Note the URL provided to access the system
  - Example: https://192.168.1.110:8006

# Configure Host
## Log in
- Log in to the Web GUI `https://<IP_ADDRESS>:8006`
  - Username: `root`
  - Password: *the password you selected*
  - Realm: Linux PAM standard authentication
- WARNING: You do not have a valid subscription for this server. Please visit www.proxmox.com to get a list of available options.
  - "The enterprise repository is enabled, but there is no active subscription!"

## Updates
- From the left menu, expand **Datacenter** > **proxymox-lab**
- Click Updates then click Refresh
  - You will be bombarded with errors because there is no paid subscription
- Click Upgrade to open a separate shell window; accept the updates

## What is next?
repositories

https://pve.proxmox.com/pve-docs/chapter-sysadmin.html
