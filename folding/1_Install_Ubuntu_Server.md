# Install Ubuntu Server
In this step we will install Ubuntu Server 22.04 LTS.
- Benefits of the LTS version: https://www.makeuseof.com/why-use-ubuntu-lts-releases/

See the tutorial at https://ubuntu.com/tutorials/install-ubuntu-server#1-overview

## Create Bootable Installation USB stick
- Download the latest ISO file: https://ubuntu.com/download/server
  - for this lab use Ubuntu 22.04 LTS
  - downloaded file named similar to `ubuntu-22.04.4-live-server-amd64.iso`
- Create a bootable USB stick from the ISO file
  - Use [balenaEtcher](https://etcher.balena.io/#download-etcher)
    - on Windows workstation, the Portable version is perfect for the task
    - Click **Flash from file** and select the downloaded ISO file
    - Click **Select target** and select the USB stick you inserted
    - Click **Flash!** and allow the command shell to continue
    - Wait for the flash and verification to complete
    - Safely eject the USB stick ([tip](https://github.com/doritoes/NUC-Labs/blob/lab-1/Stack_of_NUCs/Appendix_Safely_Eject.md))
      - yes, there are two "drives" on the USB stick

## Boot from Installation USB stick
- Boot the NUC from the bootable USB stick
  - Connnect to keyboard, mouse and power
  - Connect to wired network for faster setup
  - Insert the USB stick
  - Reboot or power on the NUC
  - Press F10 at the boot promppt
  - Select the USB stick (USB UEFI)
- Follow the prompts to install Ubuntu on the NUC
  - using the Minimal installation will save storage space
  - enabling SSH on the server now will save you the step of adding it later
  - once you answer the prompts and select **Erase disk and install Ubuntu**, you are nearly there
  - once installation starts, it will take a while
  - remove the USB stick when prompted and press **Enter**

## Update Packages
- Log in
- Do the usual package update
  - `sudo apt update && sudo apt upgrade -y`
  - enter your password when prompted



First Login

Update Packages

Learning More
Remote access
`sudo apt update && sudo apt install openssh-server -y`
