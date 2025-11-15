# XCP-ng Lab
The mission in this Lab is to set up a virtual Lab environment hosted on a NUC running XCP-ng. This replaces the previous Lab running on ESXi, which is not longer an option for home labs after the Broadcom acquisition of VMware.

UPDATE This lab is getting a refresh for XCP-ng 8.3 LTS. This is imporant since prior versions did not support a virtual VTPM, which affects Windows 11 and Windows server.

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

Left to do:
- 🌱 Tor transparent proxy
- 🌱 VPN transparent proxy
- 🌱 L2 OPNsense firewall
- 🌱 Get Windows 11 working

Out of scope:
- XCP-ng Center
  - Windows-based management tool for XCP-ng and Citrix® XenServer® environments
  - Center is no longer end of life/EOL
  - https://github.com/xcp-ng/xenadmin

Materials:
- Lab router  providing DHCP and internet access
- NUC
  - NUC10FNH (BXNUC10i7FNH1) ([specs](https://www.intel.com/content/dam/support/us/en/documents/intel-nuc/NUC10i357FN_TechProdSpec.pdf))
  - 32GB RAM (64GB max)
  - 2TB SSD
  - TIP From BIOS disable the SDHC card slot, since XCP-ng doesn't have drivers for it
  - TIP Running a hypervisor and the NUC might be a reason to disable the feature to disable the "Fan off when cool" feature; by default the fan will stop for temperatures under 40C
- USB sticks
  - 1 USB stick 8GB or more for installation of XCP-ng
 
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

## Install VMs on LAN
[Install LAN VM](5_LAN_VM.md) configures VMs on the internal LAN

## Install OPNsense firewall
[Install OPNsense](6_OPNsense_VM.md) adds firewall to isolate our pen-testing network. The VMs on this network can only access each other and the Internet. 🌱 The Tor configuration is currently not working.

IMPORTANT Be sure to <ins>disable TX checksumming</ins> on the network interfaces connected to the firewall as noted.

## Set Up Pen Testing Lab
[Set Up Lab](7_Pentesting_Lab.md) will take you into setting up Kali Linux and OpenVAS for the first time

## Install Check Point Firewall
[Install Check Point](8_Checkpoint.md) steps you through setting up a lab for testing the Check Point security gateway product.

# Automation with Ansible
[Automation with Ansible](9_Ansible.md) is supported for XenServer, so here we test it with XCP-ng.

# Appendices
- [Appendix - Lab Architecture](Appendix-Architecture.md)
- [Appendix - Active Directory Notes](Appendix-Active_Directory_Notes.md)
- [Appendix - Windows Domain Controller](Appendix-Windows_DC.md)
- [Appendix - Windows File Server](Windows_File_Server.md)
- [Appendix - Layer 2 Firewall](Appendix-L2_Firewall.md)
- [Appendix - Terraform](Appendix-Terraform.md)
- [Appendix - Ansible Manage Windows](Appendix-Ansible_Manange_Windows.md)
- [Appendix - Convert Guacamole to HTTPS](Appendix-Guacamole_https.md)
- [Appendix - Debloat Windows 11](Appendix-Debload-Windows11.md)
- [Appendix - Display Resolution](Appendix-Display_Resolution.md)
- [Appendix - L2 Firewall](Appendix-L2_Firewall.md)
- [Appendix - Build VyOS ISO with VM agents](Appendix_Build_VyOS_ISO_with_VM_agents.md)
- Installing older operating systems for the pentesting lab
  - [Ubuntu 4.10](Appendix-Ubuntu-4.10.md)
  - [Windows XP](Appendix-Windows-XP.md)
  - [Windows 7](Appendix-Windows-7.md)
  - [Windows 8.1](Appendix-Windows-8.1.md)
  - [Windows Vista](Appendix-Windows-Vista.md)
  - [Windows Server 2003](Appendix-Windows-Server-2003.md)

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

With Windows, install the tools from https://www.xenserver.com/downloads

If your distribution of Linux is not recognized by the install script
- Download the tools for Linux from https://www.xenserver.com/downloads
- Install while specifying the distribution and major release when installing. Here is an example for Check Point Gaia OS R82, based on RHEL EL8.
- `tar xzvf LinuxGuestTools-8.4.0-1.tar.gz`
- `cd LinuxGuestTools-8.4.0-1`
- `./install -d rhel -m el8`
