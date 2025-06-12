# VyOS Router
In this step we will create a virtual router for the sole purpose of demonstrating Nautobot control of it.

## Download the ISO
1. Go to https://vyos.io
2. Click Rolling Release (the free version is limited to the Rolling Release)
4. Download the most recent image (e.g., 2025.06.06-0019-rolling = vyos-2025.06.06-0019-rolling-generic-amd64.iso)

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
  - Safely eject the USB stick
- Boot the NUC from the bootable USB stick
  - Connect to keyboard, mouse and power
    - Optionally connect to wired network for faster setup
  - Insert the USB stick
  - Reboot or power on the NUC
  - Press F10 at the boot prompt
  - Select the USB stick

## Option 2 - VM
- Create a new VM based on the ISO
  - VMware Workstation Pro example:
    - File > New Virtual Machine
    - Typical
    - Browse to select the ISO file you downloaded (it will automatically detect distribution and version)
      - Since the OS isn't automatically detected, we will select Linux > Other Linux 6.x kernel 64-bit
      - VyOS is a Debian GNU / Linux-based network OS 
    - Name: **vyos**
    - Disk: 8GB
    - Customize Hardware:
      - Memory: 1GB
      - vCPU: 2 vCPU (Did you get a kernel panic in the VyOS VM? Try 2 vCPUs not 1)
      - Network Adapter: Bridged, connect at power on
      - **Add** Network Adapter (Network Adapter 2)
        - Custom: Specific virtual network: VMnet2
      - **Add** Network Adapter (Network Adapter 3)
        - Custom: Specific virtual network: VMnet2
        - Add 2 virtual switches LAN and DMZ
        - Add 1 interface connected to LAN
        - Add 1 interface connected to DMZ
    - Finish
- Power on the VM (if it doesn't automatically power on)
- Click "I Finished Installing"
- Access the system console

## Initial VyOS Installation
- Login as `vyos`/`vyos`
- `install image`
- Allow installation to continue with default values
  - Enter the new password for the `vyos` user
    - Fun fact, it allows you to set the password to `vyos`
- When done reboot: `reboot`
- Eject the VyOS iso or remove the USB flash drive
- Log back in with your updated password
- Configure your router's "management" connection (your Lab network)
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

## Next Steps
You can now start to add your devices. Continue to [Adding your First Devices](4_Adding_Devices.md).
