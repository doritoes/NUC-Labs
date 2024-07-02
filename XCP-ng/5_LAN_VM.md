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
    - you are probmoted to enter your password
    - you are prompted accept the change
    - you are reminded to reboot
  - `sudo reboot`
- Test the VM
  - Updates
    - `sudo apt update && sudo apt upgrade -y`
  - Internet access
- Power down the VM
- Take a Snapshot
  - Click New snapshot
- Convert to a Template
  - Click Advanced > Convert to template
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
- Optionally create another VM from the same template.


# Ubuntu Server

# Windows 10

# Windows 11

# Windows 2020 Server



