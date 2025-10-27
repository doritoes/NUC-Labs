# Tested Windows Vista Installations
NOTE This is for the pentesting Lab environment.

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
- Uncheck Automatically activate Windows when I'm online and **Next**, and **No**
- Select **Windows Vista Ultimate** check the box, the click **Next**
- Check the box and **Next**
- Click **Custom (advanced)**
- Click **Next** to accept Disk 0
- Enter and username, password, and password "hint", then click **Next**
- Enter computer name, then **Next**
- Enter a password and password "hint" then next
- Click **Ask me later** since Vista is no longer supported
- Set date/time and timezone, then **Next**
- Computer's location **Work network** (feel free to experiment) and Next
- Click **Start**
- When installation is complete, eject the installation ISO

Testing:
- got IP address from OPNsense firewall OK
- the tools ISO didn't install the tools correctly, can't reach the web site to download
- http access "works" like http://icanhazip.com and somewhat abcnews.com
- but a lot of things are broken like http://sethholcomb.com
- https things break because IE 7 is REALLY insecure
- 🌱 Does it work outside the pentesting lab?
