# NUC 1

This is the first NUC in our ["Stack of NUCs"](https://www.unclenuc.com/lab:stack_of_nucs:start)
- user-friendly desktop installation
- workstation to operate the lab and other NUCs from
- used to create the rest of the environment
  - create modified ISO for the boot USB stick
  - create boot USB stick for the new ISO
  - create CIDATA USB stick
  - create firmware upgrade USB stick
  - create SSH management keys
  - connect to the other NUCs you build

Hardware:
- Intel NUC model [BOXNUC7i3BNK](https://ark.intel.com/content/www/us/en/ark/products/95069/intel-nuc-kit-nuc7i3bnk.html)
- 16GB RAM (8GB is my recommendation)
- 128GB storage (64GB is my recommendation; at 32GB you will run low on disk space)
- Wireless card (makes it much easier to run large stacks of NUCs without the extra network cables)

Software:
- Ubuntu 22.04 LTS desktop - https://releases.ubuntu.com/jammy/

## Install Ubuntu Desktop
See the tutorial https://ubuntu.com/tutorials/install-ubuntu-desktop#1-overview
- Download the [latest ISO file](https://ubuntu.com/download/desktop)
- Create a bootable USB stick from the ISO
  - 💡[balenaEtcher](https://etcher.balena.io/#download-etcher) is recommended to create a bootable USB stick from the ISO
  - If your workstation is Windows, the Portable version is perfect for the task
  - Click **Flash from file** and select the downloaded ISO file
  - Click **Select target** and select the the USB stick you inserted
  - Click **Flash!** and allow the command shell to continue
  - Wait for the flash and verification to complete
  - Safely eject the USB stick (yes, there are two "drives" on the USB stick)
- Boot the NUC from the bootable USB stick
  - Connnect to keyboard, mouse and power
    - Optionally connect to wired network for faster setup
  - Insert the USB stick
  - Reboot or power on the NUC
  - Press F10 at the boot promppt
  - Select the USB stick (USB UEFI)
- Follow the prompts to install Ubuntu on the NUC
  - Allow the system to come up to the "Install" screen and click **Install Ubuntu**
  - Accept the keyboard settings
  - Configure the wifi connection now (if you are wired, you won't be prompted; set it up later)
  - There is no wrong answer for the packages screen; accept the defaults or modify as desired
  - Select **Erase disk and install Ubuntu**
  - Click **Intall Now**
  - Click **Continue** and write changes to disk
  - Accept the zime zone settings
  - Enter system and user information *you can modify these as desired*
    - Name: **nuc**
    - Computer name: **nuc1**
    - Username: **nuc**
    - Password: **nuc**
    - Require password to log in
    - Continue
  - Wait patiently for the **Installation Complete** message
  - Click **Restart Now**
  - Remove the USB stick when prompted and press Enter

💡 You cannot SSH to NUC1 at this point.

## Set up System
These steps are performed while logged in to NUC1

### First Login
- Log in with your username and password
- Answer the prompts to the first-time wizard
  - Skip connecting your online accounts
  - Skip Ubuntu pro
  - Choose NO to send information
- You will be prompted to update the system
  - This is optional; click **Install Now** (and wait) or close out the window

### Update Packages
- Log in to NUC1
- Open the **Terminal** ([tip](https://www.wikihow.com/Open-a-Terminal-Window-in-Ubuntu))
- Update the system and install packages required for this Lab
~~~~
sudo apt update && sudo apt upgrade -y
sudo apt install xorriso squashfs-tools python3-debian gpg liblz4-tool arp-scan notepadqq python3-pip -y
~~~~

### Generate SSH Key
- `ssh-keygen -o`
  - Accept default settings and don't enter a passphrase

# Learn More
## Finding your the IP address of NUC1
https://help.ubuntu.com/stable/ubuntu-help/net-findip.html.en
## Remote access to NUC1
- https://linuxize.com/post/how-to-enable-ssh-on-ubuntu-20-04/
- https://www.itpro.com/mobile/remote-access/368102/how-to-remote-desktop-into-ubuntu
  - `sudo apt update && sudo apt install openssh-server -y`
## Remmina Remote Desktop client
Installing Remmina on NUC1 is a handy way to connect to your other Lab systems
- RDP to Windows machines
- SSH
- VNC
- More!
