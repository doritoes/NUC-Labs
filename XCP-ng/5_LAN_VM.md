# Install Lab VM
Next we will install our first VM(s). These are on the Inside/LAN network, located behind our VyOS router.

Instuctions are provided for a few different systems you might want to install.

NOTE You will need to upload/copy the appropriate ISO file to one of the SR's (storage repositories) configured earlier

# Ubuntu Desktop
- From the left menu click New > VM
  - Select the pool
  - Template: Ubuntu Jammy Jellyfish 22.04
  - Name: ubuntu-desktop-lan
  - Description: Ubuntu desktop on LAN network
  - CPU: 1 vCPU
  - RAM: 2GB
  - Topology: Default behavior
  - Install: ISO/DVD: Select the Ubuntu 22.04 Desktop image you uploaded
  - Interfaces: select Inside from the dropdown
  - Disks: **20GB** (default 10GB is NOT enough; minimim is 14.8GB)
  - Click Create
- The details for the new VM are now displayed
- Click Console
- Follow the Install wizard per usual
- To remove the installation media, click the Eject icon
- Press Enter to Reboot
- Install guest tools
  - Connect the guest-tools.iso (select it from the dropdown)
    - it will be automatically mounted at /media in a folder that is the user name
    - if the user name is `lab`, the directory is `/media/lab`
  - Open terminal
  - `cd /media`
  - `ls`
  - "cd" to the user's folder (i.e. "cd lab")
  - `ls`
  - You will see the "XCP-ng Tools" folder
  - `cd XCP[tab]` then press enter (to auto-complete the name since it has a space in it)
  - `sudo Linux/install.sh`
    - you are prompted to enter your password
    - you are prompted accept the change
    - you are reminded to reboot
  - `sudo reboot`
  - Eject guest-tools.iso
- Test the VM
  - Updates
    - `sudo apt update && sudo apt upgrade -y`
  - Internet access
- Power down the VM
- Take a Snapshot
  - Click New snapshot
- Convert to a Template
  - Click Advanced > Convert to template
- Confirm the Snapshot has been erased (!) It was bound to the VM.
- Re-create the VM from the template
  - New VM
  - Template: ubuntu-desktop-lan
  - Interface: Note that it's set to Inside, which is what we want
  - Click Create
- Log back in examine the system
  - What are the advantages of using DHCP in the lab for these templates?
  - Change hostname
    - View current hostname: `hostnamectl`
    - Set the new hostname: `sudo hostnamectl set-hostname desktop-lan`
    - Optionally set the pretty name: `sudo hostnamectl set-hostname "Ubuntu Desktop on LAN" --pretty`
    - Confirm it has changed: `hostnamectl`
- Optionally create another VM from the same template and experiment

# Ubuntu Server
- From the left menu click New > VM
  - Select the pool
  - Template: Ubuntu Jammy Jellyfish 22.04
  - Name: ubuntu-server-lan
  - Description: Ubuntu server on LAN network
  - CPU: 1 vCPU
  - RAM: 2GB
  - Topology: Default behavior
  - Install: ISO/DVD: Select the Ubuntu 22.04 Server image you uploaded
  - Interfaces: select Inside from the dropdown
  - Disks: **20GB** (default 10GB is enough for the 4.3GB used)
  - Click Create
- The details for the new VM are now displayed
- Click Console
- Follow the Install wizard per usual
  - READ CAREFULLY the Guided storage configuration
    - Root / only has 10GB of the 20GB allocated
    - Option 1 expand root /
      - Under used devices, locate ubuntu-lv which will be mounted at root /
      - Select it, and then Edit
      - Change the Szie to the max value
    - Option 2
      - Select the free space, then Create Logical Volume
      - Adjust the size to use the free space
      - Adjust the mount point (/home by default)
      - Choose Create
  - Recommend checking the box Install OpenSSH server
- To remove the installation media, click the Eject icon
- Press Enter to Reboot
- Check the system
  - df -h
  - Is the disk size correct?
- Install guest tools
  - Connect the guest-tools.iso (select it from the dropdown)
  - Open terminal
  - Mount the iso
    - `sudo mount /dev/cdrom /media`
    - `cd /media/Linux`
  - Install the tools
    - `sudo ./install.sh`
    - you are prompted to enter your password
    - you are prompted accept the change
    - you are reminded to reboot
  - Unmount the ISO
    - `cd ~`
    - `sudo umount /media`
  - `sudo reboot`
  - Eject guest-tools.iso
- Test the VM
  - Updates
    - `sudo apt update && sudo apt upgrade -y`
    - accept the messages
- Power down the VM
- Convert to a Template
  - Click Advanced > Convert to template
- Re-create the VM from the template
  - New VM
  - Template: ubuntu-server-lan
  - Install settings: note that you can add a custom configuration if desired
  - Interface: Note that it's set to Inside, which is what we want
  - Click Create
- Log back in examine the system
  - What are the advantages of using DHCP in the lab for these templates?
  - Change hostname
    - View current hostname: `hostnamectl`
    - Set the new hostname: `sudo hostnamectl set-hostname server-lan`
    - Optionally set the pretty name: `sudo hostnamectl set-hostname "Ubuntu Server on LAN" --pretty`
    - Confirm it has changed: `hostnamectl`
- Optionally create another VM from the same template and experiment
  - How could you use Templates to quickly roll out a number of servers of the same type?

# Windows 10

# Windows 11

# Windows 2020 Server



