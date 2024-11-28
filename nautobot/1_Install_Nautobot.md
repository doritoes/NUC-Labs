# Install Nautobot
This corresponds to chapter 3 in the book.

## Network Architecture
For this Lab you can install in your home lab network.

## Install Ubuntu Server
The first step is to install Ubuntu Server, upon which we will install Nautobot. This lab was primarily tested on VMware Workstation Pro.

See the tutorial https://ubuntu.com/tutorials/install-ubuntu-desktop#1-overview

### Option 1 - NUC
- Download the [latest ISO file](https://ubuntu.com/download/server)
  - For this Lab we are using Ubuntu Server 24.04 LTS
- Create a bootable USB stick from the ISO
  - 💡[balenaEtcher](https://etcher.balena.io/#download-etcher) is recommended to create a bootable USB stick from the ISO
  - If your workstation is Windows, the Portable version is perfect for the task
  - Click **Flash from file** and select the downloaded ISO file
  - Click **Select target** and select the the USB stick you inserted
  - Click **Flash!** and allow the command shell to continue
  - Wait for the flash and verification to complete
  - Safely eject the USB stick (yes, there are two "drives" on the USB stick) ([tip](Appendix_Safely_Eject.md))
- Boot the NUC from the bootable USB stick
  - Connect to keyboard, mouse and power
    - Optionally connect to wired network for faster setup
  - Insert the USB stick
  - Reboot or power on the NUC
  - Press F10 at the boot prompt
  - Select the USB stick (USB UEFI)
- Follow the prompts to install Ubuntu on the NUC

### Option 2 - VM
- Download the [latest ISO file](https://ubuntu.com/download/server)
  - For this Lab we are using Ubuntu Server 24.04 LTS, and the file name is similar to `ubuntu-24.04.1-live-server-amd64.iso`
- Create a new VM that is based on the ISO we downloaded
  - There are a lot of options: VMware Workstation, Oracle VirtualBox, proxmox, XCP-ng, etc.
    - For example, on VMware Workstation Pro:
      - File > New Virtual Machine
      - Typical
      - Browse to select the ISO file you downloaded (it will automatically detect the distribution and version)
      - Name: nautobot
      - Disk: 80GB or more (not aware of a minimum value)
      - Customize Hardware
        - Memory: 2GB or more (testing 4GB in Lab)
        - vCPU: 2 or more (testing 4 in the Lab)
        - Network Adapter: Bridged, connect at power on

### Initial Ubuntu Server Installation
- Allow the system to come up to the "Install" screen and click **Install Ubuntu**
- Accept the language settings and optionally update the installer
- Accept the keyboard settings then accept **Ubuntu Server**
- Accept or configure the network connection (DHCP is fine for this Lab, but in production you want a fixed IP address: either a static IP or use a DHCP reservation)
- No proxy, and continue after the mirror passes tests
- Accept the entire disk and default settings
- **Edit** the root partition to use all the available space
  - ubutntu-lv [...] mounted at /
  - Edit it
    - Change size to the maximum size (i.e., 77.996G)
    - Save
- Done and then Continue
- Enter system and user information *you can modify these as desired*
  - Your name: **nauto**
  - Server name: **nautobot**
  - Username: **nauto**
  - Password: **nautolab5**
  - Require password to log in
  - Continue
- Skip Ubuntu Pro
- Select Install Don't select any feature server snaps, Done
- Wait patiently for the **Installation complete!** message
- Select **Reboot Now**
  - Remove the installation media (USB stick or ISO file) when prompted and press **Enter**

## Set up System
These steps are performed while logged in to `nautobot`

### Update Packages
- `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`

### System Dependencies
- `sudo apt install -y python3 python3-pip python3-venv python3-dev`

### Redis setup

### Database (PostgeSQL) setup

### Install Nautobot

### Configure Nautobot

## Launch Nautobot
