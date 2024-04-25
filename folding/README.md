# FAH Folding on Ubuntu Server
💡What is Folding At Home? It's a way to donate CPU and/or GPU cycles to help cure diseases. Your computer will simulate protein dynamics, including the process of protein folding.

Why fold on a NUC?
- Pros
  - NUCs are very energy efficient
  - NUCs are often not "busy" and have available CPU cycles to donate
- Cons
  - NUCs don't have GPUs that are capable for Folding
  - CPU Fans are quite small and can wear out (yes I have replaced a CPU fan on folding NUC after months of maximum Folding)

This is a simple Lab that walks you through installing the Folding at Home (FAH or F@H) client and running it as a service. It is ideal to run on a mid-sized NUC such as the 8i5. 8GB RAM and 128GB storage is the recommended minimum.

Mission:
- Install Unbuntu server on a NUC (minal installation)
- Install the FAH Client as a service

Materials:
- NUC
  - Works on any NUC, but runs best on a NUC with 4 CPUs
  - 8GB RAM or more
  - 128GB storage or more

Network:
- Router with DHCP for the host (to allow downloading work units and uploading results)
- NUC will use DHCP for network addressing

## Overview
Before starting the Lab, you might review [Preparing NUCs for Labs](https://www.unclenuc.com/lab:preparing_nucs_for_labs). The will help you prepare all the NUCs for use.

### Install Ubuntu Server
The first step is to install Ubuntu Server 22.04 LTS on the NUC.

[Install Ubuntu Server](1_Install_Ubuntu_Server.md)

### Install FAH Client
[Intall FAH Client](2_Install_FAH_Client.md)

### Configure FAH Client
🚧To be continued

### Set up FAHClient service
🚧To be continued

### Review
Review the technologies and concepts introduced in this lab

🚧To be continued
