# Install Proxmox VE
References:
- https://www.proxmox.com/en/proxmox-virtual-environment/get-started
- https://phoenixnap.com/kb/install-proxmox

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

# Configure Community Repositories
Reference: https://pve.proxmox.com/wiki/Package_Repositories
- `vi /etc/apt/sources.list.d/pve-enterprise.list`
  - Comment out line:
    - `#deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise`
- `vi /etc/apt/sources.list.d/ceph.list`
  - Comment out line:
    - `#deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise`
  - Add line:
    - `deb http://download.proxmox.com/debian/ceph-reef bookworm no-subscription`
- `vi /etc/apt/sources.list`
  - Add line:
    - `deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription`
- `apt update`

Complete `sources.list` file:
~~~
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib

# Proxmox VE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# security updates
deb http://security.debian.org/debian-security bookworm-security main contrib
~~~
