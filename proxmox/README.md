# proxmox Lab
The mission in this Lab is to set up a virtual Lab environment hosted on a NUC running proxmox. This replaces the previous Lab running on ESXi, which is not longer an option for home labs after the Broadcom acquisition of VMware.

Why it's perfect to the lab:
- ProxmoxVE is super-flexible and feature-rich, perfect for the Lab
- Easy to use Ceph support for cobbling together storage

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


Mission:
- Bare metal installation on the NUC
- Set up guest VMs
- Set up LXD containers
- Test automation that is available

Left to do:
- Everything

Out of scope:
- Still scoping
- ACME certificate automation
- CEPH

IMPORTANT:
- Post important gotchas, limitations, "before you start" notes
- guest tools???
- how to install community edition so it doesn't keep bombing you will no subscription and errors
- the proxmox logon on every screen takes you to sales site, not the root menu
- login TFA = two factor authentciation
- uses noVNC
- gives direct access to the network guts: Linux Bridge vmbr0
- certificates: exposes ACME for certificate  management
- exposes a firewall

Materials:
- Lab router  providing DHCP and internet access
- NUC
  - NUC10FNH (BXNUC10i7FNH1) ([specs](https://www.intel.com/content/dam/support/us/en/documents/intel-nuc/NUC10i357FN_TechProdSpec.pdf))
  - 32GB RAM (64GB max)
  - 2TB SSD
  - TIP Running a hypervisor and the NUC might be a reason to disable the feature to disable the "Fan off when cool" feature; by default the fan will stop for temperatures under 40C
- USB sticks
  - 1 USB stick 8GB or more for installation of proxmox
 
References:
- [link here](https://www.proxmox.com/en/proxmox-virtual-environment/get-started)

# Overview
## Install Hypervisor on NUC Host
[Install Proxmox VE](1_Install.md)

## Connect ISO Storage
[Connect ISO Stroage](2_ISO_Storage.md)

🌱 Currently only local storage is used. Need to investigate remote ISO storage

## Install VyOS router
[Install Router](3_Router.md) outlines how to create a router to our backend "LAN".

## Install VMs on LAN

## Create CT (LXC container)
CT stands for ConTainer

In your pve gui select storage "local" -> ct templates -> templates -> search for ubuntu -> download

lightweight alternative to fully virtualized machines (VMs). They use the kernel of the host system that they run on, instead of emulating a full operating system (OS). This means that containers can access resources on the host system directly.

Only Linux distributions can be run in Proxmox Containers

For security reasons, access to host resources needs to be restricted. Therefore, containers run in their own separate namespaces. Additionally some syscalls (user space requests to the Linux kernel) are not allowed within containers.



## Install OPNsense firewall

Does we need to do this for proxmox? Be sure to <ins>disable TX checksumming</ins> on the network interfaces connected to the firewall as noted.

## Set Up Pen Testing Lab

## Automation


# Appendices
- more details

# Other Notes
