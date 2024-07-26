# proxmox Lab
The mission in this Lab is to set up a virtual Lab environment hosted on a NUC running proxmox. This replaces the previous Lab running on ESXi, which is not longer an option for home labs after the Broadcom acquisition of VMware.

Why it's perfect to the lab:
- ProxmoxVE is super-flexible and feature-rich, perfect for the Lab

Mission:
- Bare metal installation on the NUC
- Set up guest VMs
- Set up LXD containers
- Test automation that is available

Left to do:
- Everything

Out of scope:
- Still scoping

IMPORTANT:
- Post important gotchas, limitations, "before you start" notes
- guest tools???
- how to install community edition so it doesn't keep bombing you will no subscription and errors

Materials:
- Lab router  providing DHCP and internet access
- NUC
  - NUC10FNH (BXNUC10i7FNH1) ([specs](https://www.intel.com/content/dam/support/us/en/documents/intel-nuc/NUC10i357FN_TechProdSpec.pdf))
  - 32GB RAM (64GB max)
  - 2TB SSD
  - TIP From BIOS disable the SDHC card slot; 🌱 does proxmox have drivers for it? XCP-ng didn't
  - TIP Running a hypervisor and the NUC might be a reason to disable the feature to disable the "Fan off when cool" feature; by default the fan will stop for temperatures under 40C
- USB sticks
  - 1 USB stick 8GB or more for installation of proxmox
 
References:
- [link here](https://www.proxmox.com/en/proxmox-virtual-environment/get-started)

# Overview
## Install Hypervisor on NUC Host
[Install Proxmox VE](1_Install.md)

## Install VyOS router

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
