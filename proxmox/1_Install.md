# Install Proxmox VE
References: https://www.youtube.com/watch?v=fuS7tSOxcSo

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
