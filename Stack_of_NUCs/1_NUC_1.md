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
  - 💡[balenaEtcher\(https://etcher.balena.io/#download-etcher) is recommended to create a bootable USB stick from the ISO
  - If your workstation is Windows, the Portable version is perfect for the task
  - Click **Flash from file** and select the downloaded ISO file
  - Click **Select target** and select the the USB stick you inserted
  - Click **Flash!** and allow the command shell to continue
  - Wait for the flash and verification to complete
  - Safely eject the USB stick
- Boot the NUC from the bootable USB stick
  - Insert the USB stick
  - Reboot or power on the NUC
  - Press F10 at the boot promppt
  - Select the USB stick (USB UEFI)
- Follow the prompts to install Ubuntu on the NUC
  - 🚧To be continued

## Update Packages

## Create the modified ISO for USB installation of remaining NUCs
## Create the CIDATA USB stick
## Create the firmware upgrade USB stick
## Create SSH management keys
