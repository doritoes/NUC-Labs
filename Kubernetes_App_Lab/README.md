# Kubernetes App Lab
This is an advanced lab that builds on the VirtualBox Linux Lab.

This lab is sized small to be able to run on a mid-sized NUC with 4 physical CPUs (8 cores). However, it is much more enjoyable to build on a system with more cores (even if it is not a NUC). 16GB RAM and 500GB storage is the recommended minimum.

First published at [https://www.unclenuc.com/lab:stack_of_nucs:start](https://www.unclenuc.com/lab:kubernetes_app:start)

Mission:
- Use Ansible to create a Lab environment using Oracle VirtualBox
- Use Ansible to create a Kubernetes cluster in the Lab
- Deploy demonstration web application to it
  - Pod with SQL server with persistent storage
  - Pod with 2 application servers, load balanced

Materials:
- NUC
  - Recommend a more powerful NUC
  - 4 physical CPUs (8 cores) or more
  - 16GB RAM or more
  - 500GB storage or more

Network:
- Router with DHCP for the host
- Host running VirtualBox will bridge the guests to it's LAN interface
- Guests will be assigned static IP addresses on the same network as the host, attached to the router

## Overview
Before starting the Lab, you might review [Preparing NUCs for Labs](https://www.unclenuc.com/lab:preparing_nucs_for_labs). The will help you prepare all the NUCs for use.

Make sure virtualization is enabled in BIOS. For example on a NUC:
- Advanced > Security > Security Features
- Intel® Virtualization Technology
- Intel® VT for Directed I/O

### Set up the Host
The first step is to install Ubuntu 22.04 Desktop on the host system.

[Setup Host](1_Host.md)

### Deploy the VMs
Use Ansible to employ auto-installation of Ubuntu servers using Oracle VirtualBox. Then manage these VMs using Ansible.

[Deploy VMs](2_VMs.md)

### Set up Kubernetes
Now we are going to install Kubernetes on the VMs:
- The first will be the Kubernetes (k8s) master node
- The second will be the node dedicated to running the SQL service (MySQL)
- The remaining VMs will be the “worker” nodes running the web application pods

[Setup Kubernetes](3_Kubernetes.md)

### MySQL Server
Now that we have Kubernetes up and running, we will get our MySQL container up and running. We will need storage for the SQL database so that it isn't lost the pod is deleted or recreated. We also want the MySQL container/pod to run on a specific node which has more resources.

[Create MySQL Server](4_MySQL.md)
### Application Pods
We are going to deploy a demonstration web app using an image downloaded from hub.docker.com. We will demonstrate using HAProxy in front of the web application on Kubernetes.

[Setup Application](5_Web_App.md)

### Application Configuration
We will now look at deploying different application image, updating the the latest image version, and more.

[Application Configuration](6_Management.md)

### Review
Review the technologies and concepts introduced in this lab, and point in the direction of new experiments to try. And of course cleaning up the Lab.

[Review](7_Review.md)
