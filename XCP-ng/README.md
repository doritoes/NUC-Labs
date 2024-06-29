# XCP-ng Lab
The mission in this Lab is to set up a virtual Lab environment hosted on a NUC running XCP-ng. This replaces the previous Lab running on ESXi, which is not longer an option for home labs after the Broadcom acquisition of VMware.

Why it's perfect to the lab:
- Main goal of XCP-ng is to be a fully integrated and dedicated virtualization platform, without requiring any deep Linux or system knowledge
- Meant to be managed in a centralized manner via Xen Orchestra, regardless the fact you have only one host or thousand of them
- Backup is also included inside Xen Orchestra
- It's a virtual appliance easy to install

Mission:
- Bare metal installation on the NUC
- Managing the environment with (name of the tool/interface)
- Set Lab segments for pen testing, TOR testing, and more
- Set up guest VMs
- Test automation that is available

Materials:
- Lab router  providing DHCP and internet access
- NUC
  - NUC10FNH (BXNUC10i7FNH1) ([specs](https://www.intel.com/content/dam/support/us/en/documents/intel-nuc/NUC10i357FN_TechProdSpec.pdf))
  - 32GB RAM (64GB max)
  - 2TB SSD
- USB sticks
  - 1 USB sticks 8GB or more for installation of XCP-ng
 
References:
- https://xcp-ng.org/
- Install OPNsense VM on XCP-ng - https://www.youtube.com/watch?v=KecQ4AZ-RBo

# Overview
## Install Hypervisor on NUC Host
[Install XCP-ng](1_Install.md) steps through creating a bootable USB stick and installing the hypervisor


## Install Xex Orchestrator (XO) to Manage the Host
[Install XO 2 Ways](2_Install_XO.md) shows how to use the built-in quick deploy and how to build your own fully-featured manager.

## Install VyOS router
[Install Router](3_Router.md) outlines how to create a router to our backend "LAN".

## Install Ubuntu Desktop VM
[Install LAN VM](4_LAN_VM.md) configures a VM on the internal LAN

## Install OPNsense firewall
[Install OPNsense](5_OPNsense_VM.md) adds firewall to isolate our pen-testing network. The VMs on this network can only access each other and the Internet.

## Install Windows Servers
Install Windows servers on the pen-testing network.

## Install Kali Linux VM
Install Kali Linux VM on the pen-testing network.

## Convert Pentest Network to TOR Only
Use OPNsense to only allow access to the Internet over TOR

## Create Ubuntu Desktop FAH VM
Demonstrate Internet access works over TOR (only)

## Install Check Point Firewall

# Appendices
- [Appendix - Lab Architecture][Appendix_- Architecture.md]