# Tested Windows XP Installations
NOTE This is for the pentesting Lab environment.

IMPORTANT Requires and XP Pro licence key (https://github.com/fuwn/xp)

ISO: en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso
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
- Press Enter to set up Windows XP
- Press F8
- Press Enter to install on Disk 0
- Select **Format the partition using the NTFS file system (Quick)** and press Enter
- Review regional and language options and click **Next**
- Enter Name and Organization
- Enter 25-character Volume License product key
- Enter computer name and an Administrator password
- Confirm time settings
- Network Settings: Typical settings
- Select **No** and leave the workgroup name WORKGROUP
- At Display Settings, select OK, then decide if you want revert the display
- At the login screen, eject the installation ISO

Testing:
- graphics really glitchy
- got IP address from OPNsense firewall OK
- http access "works" like http://icanhazip.com
- but a lot of things are broken like http://sethholcomb.com
- https things break because IE 6 is REALLY insecure
- 🌱 Does it work outside the pentesting lab?
