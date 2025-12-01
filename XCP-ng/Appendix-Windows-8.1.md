# Tested Windows 8.1 Installations
NOTE This is for the pentesting Lab environment.

IMPORTANT Requires an 8.1 licence key

ISO: en_windows_vista_sp2_x64_dvd_342267.iso
- Template: Other install media
- 1 vCPU
- 2 GB RAM
- 128GB hard drive
- Boot firmware: bios

Examining advanced settings:
- NIC Realtek RTL8139
- Viridian: enabled
- VGA: disabled
Steps:
- Confirm language, time/currency format, and keybord, then click **Next**
- Click **Install now**
- Enter a product key and click **Next**
- Check the box and **Next**
- Click **Custom: Install Windows only (advanced)**
- Click **Next** to accept Disk 0
- Enter PC name and click **Next**
- Click **Express settings**
- Creating a Microsoft account will fail, click **Create a local account**
- Enter and username, password, and password "hint", then click **Finish**
- When installation is complete, eject the installation ISOchom
Testing:
- got IP address from OPNsense firewall OK
- Internet access works
- IE 11 is REALLY insecure
- https://supermium.net/ works well, Chromium for older versions of Windows
- Guest tools from https://www.xenserver.com/downloads installed but did not work
