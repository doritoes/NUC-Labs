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

Out of scope:
- XCP-ng Center - Windows client
  - Center is no longer end of life/EOL
  - https://github.com/xcp-ng/xenadmin

IMPORTANT:
- You must install XCP-ng 8.3 or later to run Windows 11 (support VTPM)
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

## Install Xen Orchestrator (XO) to Manage the Host
[Install XO 2 Ways](2_Install_XO.md) shows how to use the built-in quick deploy and how to build your own fully-featured manager.

## Connect to Storage Hosting ISO images
[Connect to ISO storage](3_ISO_Storage.md) shows the important step of mounting the ISOs you will use to build VMS.

## Install VyOS router
[Install Router](4_Router.md) outlines how to create a router to our backend "LAN".

## Install Ubuntu Desktop VM
[Install LAN VM](5_LAN_VM.md) configures a VM on the internal LAN

## Install OPNsense firewall
[Install OPNsense](6_OPNsense_VM.md) adds firewall to isolate our pen-testing network. The VMs on this network can only access each other and the Internet.

## Install Windows Servers
Install Windows servers on the pen-testing network.

## Install Kali Linux VM
Install Kali Linux VM on the pen-testing network.

## Create Vulnerable Windows Machine
See http://cyberforensic.net/labs/AutoPatch_Removal.html

## Create Vulnerable Linux Machine
See https://www.netspi.com/blog/technical-blog/network-pentesting/linux-hacking-case-studies-part-5-building-a-vulnerable-linux-server/
## Convert Pentest Network to TOR Only
Use OPNsense to only allow access to the Internet over TOR

## Create Ubuntu Desktop FAH VM
Demonstrate Internet access works over TOR (only)

## Create Guacamole Server

## Install Check Point Firewall
https://github.com/PacktPublishing/Check-Point-Firewall-Administration-R81.10-

# Appendices
- [Appendix - Lab Architecture](Appendix_- Architecture.md)

# Other Notes
## Other Install Media
If no matching template, select Other Install Media

## No Xen tools detected
After installing a Linux system, you may see this warning. Here are the stops to resolve it
1. connect guest-tools.iso
2. sudo mount /dev/cdrom  /media
3. cd /media/Linux
4. sudo ./install.sh
5. Continue
6. Reboot the VM
