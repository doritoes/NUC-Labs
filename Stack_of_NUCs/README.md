# Stack of NUCs Lab
The mission in this Lab is to create genuine hands-on experience for technology learners using the learner-friendly NUC PCs.

First published at https://www.unclenuc.com/lab:stack_of_nucs:start

Mission:
- Auto install Ubuntu servers
- Install and use Ansible to manage our servers
- Install and run a FAH protein folding cluster
- Install a Hashtopolis cluster
- Install a Kubernetes cluster and run a web application

Materials:
- Wireless router providing DHCP and internet access
- NUCs
  - 4 minimum for the Kubernetes portion; 5 recommended, or more are recommended for testing Kubernetes resiliency
  - wifi cards to make it easier to run large stacks of NUCs
  - D34010WYK was used to Lab testing as they are readily available; I used 8GB RAM and 32GB or greater mSATA SSDs
- USB sticks
  - 3 USB sticks, 8GB or more each
  - Using a pair of sticks for booting and one more for firmware upgrades

# Overview
## Set up NUC 1 - Workstation
In this step you will configure your first NUC, used to create and operate the rest of the environment.

[NUC 1](1_NUC_1.md)

## Create USB sticks for auto installation
In this step you will test building a NUC using two (2) USB sticks and an automatic installation process.

[Create USB Sticks](2_USB_stick_creation.md)

## Set up NUC 2 - Ansible controller
In this step you will configure your second NUC, used as the Ansible controller.

[NUC 2](3_NUC_2.md)

## Set up NUC 3, NUC 4, and more
In this step you will configure your remaining NUCs in the stack as the Ansible member modes.

[NUCs 3-5](4_NUC_3-5.md)

## Discover NUCs and add to Ansible inventory
Now that you have your stack of NUCs built, updated and connected to the wireless network, it is time to set them up on the Ansible inventory.

[Inventory](5_Inventory.md)

## Update and finish configuring
We will use Ansible playbooks will be to finish configuration and update Ubuntu packages on all the worker nodes.

[Update and Configure](6_Update.md)

## CMOS Battery health check
Next is a playbook to  check the CMOS battery health on the nodes.

[CMOS Battery Check](7_Battery.md)

## Folding@Home (FAH)
This section demonstrates a running a complex workload of a service combined with configuration files.

[FAH](8_FAH.md)

## Hashtopolis
Cyber security professionals use Hashtopolis to create a cluster of systems running Hashcat, a versatile password hash cracking tool. Intel NUCs don't have the power for executing proper audits, but this is a great hands-on learning experience.

[Hashtopolis](9_Hashtopolis.md)

## Kubernetes (k8s) - Installation
Install Kubernetes on your stack of NUCS.

[Kubernetes Installation](10_Kubernetes_install.md)

## Kubernetes - Deploy web application
Deploy a web application and take on challenging optional/bonus tasks include some good old chaos testing.

[Deploy Web App on Kubernetes](11_Kubernetes_web_app.md)

## Kubernetes - Test HAProxy
No Kubernetes lab would be complete without HAProxy.

[Kubenetes HAProxy](12_Kubernetes_HAProxy.md)

## Cleanup and Next Steps
[Next Steps](13_Next_Steps.md)


