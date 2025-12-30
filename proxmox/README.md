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
- Full virtualization (KVM)

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
- VMs
- Templates
- Inside VMs
- CT - containers
- OPNsense
- Pentesting lab

Out of scope:
- Pools and multiple hosts
- ACME certificate automation
- CEPH
- SDN features (Zones, VNets, Options, IPAM)
- Firewall
- Metrics server (Graphite, InfluxDB)

IMPORTANT:
- Post important gotchas, limitations, "before you start" notes
- guest tools???
- how to install community edition so it doesn't keep bombing you will no subscription and errors
- the proxmox logon on every screen takes you to sales site, not the root menu
- login TFA = two factor authentication
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
[Connect ISO Storage](2_ISO_Storage.md)

## Install VyOS router
[Install Router](3_Router.md) outlines how to create a router to our backend "LAN".

## Install VMs on LAN
Next we will [Install VMs](4_LAN_VM.md) on the backend "LAN".

## Create CT (LXC container)
An interesting feature of proxmox is its use of [CT (LXC containers)](5_LAN_CT.md)
Next we will [Install VMs](4_LAN_VM.md) on the backend "LAN".

## Install OPNsense firewall
Installing [OPNsense](5_OPNsense_VM.md) adds a firewall to isolate our pen-testing network from the outside. The VMs on this network can only access each other and the Internet (if access to the Internet is enabled).

🌱 The Tor configuration is currently not working.

OPNsense on proxmox can be a challenge because there is no easy way to disable hardware checksum offloading. When proxmox is used to run OPNsense as a border firewall leading to the Internet, the standard approach is to add a NIC and do PCI passthru (to isolate the card from the PROXMOX hypervisor).
 
## Set Up Pen Testing Lab
[Set Up Lab](6_Pentesting_Lab.md) will take you into setting up Kali Linux and OpenVAS for the first time

## Automation
[Advanced Automation](7_Advanced_Automation.md) will take you through an advanced scenario with Cloud-init, Terraform, and Ansible.
