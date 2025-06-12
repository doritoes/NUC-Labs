# VyOS Router
In this step we will create a virtual router for the sole purpose of demonstrating Nautobot control of it.

## Download the ISO
1. Go to https://vyos.io
2. Click Rolling Release
  - the free version is limited to the Rolling Release
4. Download the most recent image

## Option 1 - NUC
Use an additional NUC to perform as the router.

NOTE this will limit your testing options as it only has one network interface.

- Create a bootable USB stick from the ISO
  - 💡[balenaEtcher](https://etcher.balena.io/#download-etcher) is recommended to create a bootable USB stick from the ISO
  - If your workstation is Windows, the Portable version is perfect for the task
  - Click **Flash from file** and select the downloaded ISO file
  - Click **Select target** and select the the USB stick you inserted
  - Click **Flash!** and allow the command shell to continue
  - Wait for the flash and verification to complete
  - Safely eject the USB stick (yes, there are two "drives" on the USB stick)
- Boot the NUC from the bootable USB stick
  - Connect to keyboard, mouse and power
    - Optionally connect to wired network for faster setup
  - Insert the USB stick
  - Reboot or power on the NUC
  - Press F10 at the boot prompt
  - Select the USB stick (USB UEFI)

## Option 2 - VM
- Create a new VM based on the ISO
  - VMware Workstation Pro example:
    - File > New Virtual Machine
    - Typical
    - Browse to select the ISO file you downloaded (it will automatically detect distribution and version)
    - Name: **vyos**
    - Disk: 8GB
    - Customize Hardware:
      - Memory: 1GB
      - vCPU: 2 vCPU (Did you get a kernel panic in the VyOS VM? Try 2 vCPUs not 1)
      - Network Adapter: Bridged, connect at power on
        - Add 2 virtual switches LAN and DMZ
        - Add 1 interface connected to LAN
        - Add 1 interface connected to DMZ
- Power on the VM
- Access the system console

## Initial VyOS Installation
- Login as `vyos`/`vyos`
- `install image`
- Allow installation to continue with default values
  - Enter the new password for the `vyos` user
    - Fun fact, it allows you to set the password to `vyos`
- When done reboot: `reboot`
- Eject the VyOS iso
- Log back in with your updated password
- Configure your router's "Internet" connection (your Lab network via the host's ethernet interface)
  - `configure`
  - `set interfaces ethernet eth0 address dhcp`
  - `set service ssh`
  - `commit`
  - `save`
  - `exit`
- View your router's IP address
  - `show interfaces ethernet eth0 brief`
- You can now configure your router from another device in your Lab; SSH to this IP address

TIP Set up a DHCP reservation for your Nautobot server so it always has the same IP address
  - Home router: https://www.youtube.com/watch?v=dCAsHdRBrag
  - pfSense: https://www.youtube.com/watch?v=NNKZm49keaA
  - OPNsense: https://forum.opnsense.org/index.php?topic=34017.0
