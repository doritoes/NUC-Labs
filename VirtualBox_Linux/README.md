# VirtualBox Linux Lab
The mission is this Lab is to create genuine hands-on experience for hands-on learnings who want to learn to use Ansible to create auto-installing Ubuntu ISOs and use them to stand up a server lab in Oracle VirtualBox.

Mission
- Install Ansible and other required packages on a new Ubuntu system
- Prepare ssh keys for managing the Ansible servers
- Install VirtualBox using Ansible
- Customize the user-data for unattended installation
- Create a custom Ubuntu server ISO that automatically installs
- Deploy our first Ubuntu VM to Oracle VirtualBox
- Test our first Ubuntu VM
- Delete our first Ubuntu VM
- Deploy our first fleet of VMs
- Deploy an application to our fleet of VMs

Materials
- NUC
  - Recommend a more powerful NUC with 16GB RAM and 500GB disk space
    - Most mid-range NUCs have 4 physical CPUs for a total of 8 cores. Most Gen12 and Gen13 NUCs have more cores available.
  - Yes you can create an VM in VMware and run Oracle VirtualBox…
    - <ins>IF</ins> you enable “Virtualize Intel VT-x/EPT or AMD-V/RVI” under Settings > Processors in VMware
    - <ins>BUT</ins> However, I had issues the network connectivity on the Oracle guests, both bridging and NATting. Setting the promiscuous mode settings on the VirtualBox guest didn't solve the issue.
   
References
- https://rutgerblom.com/2020/07/27/automated-ubuntu-server-20-04-installation-with-ansible/ ([Gitlab](https://github.com/rutgerblom/ubuntu-autoinstall/blob/default/DeployUbuntu.yml))
- https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/

## Overview
Before starting the Lab, you might review [Preparing NUCs for Labs](https://www.unclenuc.com/lab:preparing_nucs_for_labs). The will help you prepare the NUC for use.

Make sure virtualization is enabled in BIOS. For example on a NUC:
- Advanced > Security > Security Features
- Intel® Virtualization Technology
- Intel® VT for Directed I/O

### Set up the Host
The first step is to install Ubuntu 22.04 Desktop on the host system.

[Setup Host](1_Host.md)

### Generate Custom Unattended Ubuntu Install ISO
[Custom ISO](2_Custom_ISO.md)

### Deploy our first Ubuntu Server VM to Oracle VirtualBox using Ansible
[Deploy First VM](3_Deploy_First.md)

### Test our first Ubuntu VM
[Test First VM](4_Test_First.md)

### Deploy our first fleet of VMs
[Deploy Fleet of VMs](5_Deploy_Fleet.md)

### Deploy a Web Application to our Fleet of VMs
In this step will deploy a placeholder web application to the servers. If you would like see similar automation using a proper demonstration web app, see [Kubernetes App Lab](/Kubernetes_App_Lab/README.md).

[Deploy Web App](7_Deploy_Web_App.md)

### Tear Down the Lab
[Destroy Fleet of VMs](8_Destroy_Fleet.md)

### Review
[Review and Next Steps](7_Review.md)
