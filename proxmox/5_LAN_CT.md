# Install CT (LXD) Containers
CT stands for ConTainer, a lightweight alternative to fully virtualized machines (VMs). LXD containers, pronounced "lex-dee", are lightweight container hypervisors that are part of Linux Containers (LXC). LXD is an open-source extension that provides new features and functionality for managing and building Linux containers. It's similar to hypervisors like KVM or VMWare, but uses fewer resources and removes virtualization overhead. 

Features:
- <ins>NOT</ins> the same as Docker or Kubernetes containers; LXD extends LXC (Linux Container) with important improvements
  - Docker isolates ONE application in ONE container; allows running multiple isolated applications on a server
  - LXC isolates ONE operating system in ONE container; allows running multiple isolated OS on a server
  - LXD improves LXC isolation, allows migration server to server while its runnning, improved resoure controls
- use kernel of the host system that they run on, instead of emulating a full operating system (OS). This means that containers can access resources on the host system directly.
- pnly Linux distributions can be run in Proxmox Containers
- For security reasons, access to host resources needs to be restricted. Therefore, containers run in their own separate namespaces. Additionally some syscalls (user space requests to the Linux kernel) are not allowed within containers.

Using pre-built templates:
- Expand **Datacenter** > **proxmab-lab**
- Click **local (proxmox-lab)**
- Click **CT templates**
- Cick **Templates**

### Ubuntu
As you perform these Lab steps, note the many options available to you
- Search for `ubuntu`
- Click on **ubuntu-22.04-standard** (feel free to customize)
- Click **Download**
- From the top ribbon, click **Create CT**
  - General tab
    - Hostname: **container-ubuntu**
    - Password: *select a password*
    - Note the default is *Unprivileged container*
  - Template tab
    - Storage: **local**
    - Template: *use the dropdown to select the template file you downloaded*
  - Disks tab
    - Storage: **local-lvm**
    - Disk size (GiB): **128GB**
  - CPU tab
    - Cores: **1**
  - Memory tab
    - Memory: **1024** MiB (1GB)
    - Swap: match memory 1024MiB (1GB)
  - Network tab
    - Bridge: **vmbr1**
    - IPv4: **DHCP**
    - Uncheck Firewall
  - DNS tab
    - DNS domain: *use host settings*
    - DNS servers: *use host settings*
  - Confirm tab
    - Check **Start after created**
    - Click **Finish**
- Click on the VM 114 (container-ubuntu)
  - Open console; start if not already started
  - Log in as user `root` with the password you selected
  - By default you cannot ssh as root with a password; use ssh with keys or add another user
- You can test the Ubuntu server container as usual
  - `apt update && apt upgrade -y && apt autoremove -y`
  - Note that under the VM's Options there is no agent to enable/disable
    - If you try to "qm agent 114 ping" from proxmox, the agent configuration file does not exist

### TurnKey LAMP Stack
- Return to download another CT template
- Search for `lamp`
- Click on **turnkey-lamp**
- Click **Download**
- From the top ribbon, click **Create CT**
  - General tab
    - Hostname: **container-lamp**
    - Password: *select a password*
  - Template tab
    - Storage: **local**
    - Template: *use the dropdown to select the template file you downloaded*
  - Disks tab
    - Storage: **local-lvm**
    - Disk size (GiB): **128GB**
  - CPU tab
    - Cores: **1**
  - Memory tab
    - Memory: **1024 MiB** (1GB)
    - Swap: match memory 1024MiB (1GB)
  - Network tab
    - Bridge: **vmbr1**
    - IPv4: **DHCP**
    - **Uncheck Firewall**
  - DNS tab
    - DNS domain: *use host settings*
    - DNS servers: *use host settings*
  - Confirm tab
    - Check **Start after created**
    - Click **Finish**
- Click on the VM 115 (container-LAMP)
  - Open console; start if not already started
  - Log in as user `root` with the password you selected
    - By default you cannot ssh as root with a password; use ssh with keys or add another user
  - Follw the first boot configuration wizard
    - Password for MySQL 'adminer`: *select a password*
    - Skip setting up TurknKey Hub services
    - Skip setting up System Notifications and Critical Security Alerts
    - Install security updates
  - Note links provided for
    - Web (ports 80 and 443)
    - Webmin (port 12321)
    - Adminer (port 12322)
    - SSH/SFTP: (port 22)
- Open Advanced Options and review the available seetings
- Browse the the IP address from a workstation the same network (e.g., `win10-desk` or `desktop-lan`)
  - Try the links on the page
