# Install Proxmox VE
References: https://www.youtube.com/watch?v=fuS7tSOxcSo

We will start with a the XOA virtual appliances, then build our own XO installation to replace it

NOTES What is Ceph and Ceph Reef? Ceph Quincy?


# Create Bootable Installation USB
- Download ISO from https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso
  - Select the latest version ISO; this Lab tested with Proxmox vE 8.2
- Create Bootable USB using [Balena Etcher](https://etcher.balena.io/)

# Initial Installation
- Boot from USB (UEFI mode) by pressing F10 on the NUC and selecting the UEFI USB stick image
- Press Enter to start the installation

# Configure Host
Initial setup

repositories

Apply updates

https://pve.proxmox.com/pve-docs/chapter-sysadmin.html
