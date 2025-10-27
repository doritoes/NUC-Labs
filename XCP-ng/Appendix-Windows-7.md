# Tested Windows 7 Installations
NOTE This is for the pentesting Lab environment.

ISO: en_windows_7_ultimate_with_sp1_x64_dvd_u_677332.iso
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
- Check the box and **Next**
- Click **Custom (advanced)**
- Click **Next** to accept Disk 0
- Enter username and computer name, then **Next**
- Enter a password and password "hint" then next
- **Skip** the product key
- **Ask me later** since Windows 7 is out of support
- Update timed/date settings and **Next**
- Computer's location **Work network** (feel free to experiment)
- Eject the installation ISO

Testing:
- got IP address from OPNsense firewall OK
- the tools ISO didn't install the tools correctly, can't reach the web site to download
- http access "works" like http://icanhazip.com and somewhat abcnews.com
- but a lot of things are broken like http://sethholcomb.com
- https things break because IE 8 is REALLY insecure
  - Chrome 107 was last to support Windows 7
  - https://github.com/e3kskoy7wqk for forks
  - https://github.com/win32ss/supermium
- 🌱 Does it work outside the pentesting lab?
