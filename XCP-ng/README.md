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
  - NUC10FNH (BXNUC10i7FNH1) ([specs](https://www.intel.com/content/dam/support/us/en/documents/intel-nuc/NUC10i357FN_TechProdSpec.pdf]))
  - X GB RAM (Y GB max)
  - 2TB SSD
- USB sticks
  - 1 USB sticks 8GB or more for installation of XCP-ng
 
References:
- https://xcp-ng.org/

# Overview
## Install Hypervisor on NUC Host
[Install XCP-ng](1_Install.md) steps through creating a bootable USB stick and installing the hypervisor and the Xen Orchestrator VP to manage it

## Install VyOS router

## Install OPNsense firewall

## Install Windows Servers

## Install Kali Linux VM

## Install Check Point Firewall
