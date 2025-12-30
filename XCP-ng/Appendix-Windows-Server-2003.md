# Tested Windows Server 2003 R2 Installation
NOTE This is for the pentesting Lab environment.

IMPORTANT Requires an Server 2003 R2 license key (https://gist.github.com/thepwrtank18/4456b1a4676a26c6ef25b8e8b70e26d7)

ISO: Windows_Server_2003_R2_Standard_x64_CD1.isovvi
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
- Press Enter to set up Windows Server 2003
- Press F8
- Press Enter to install on Disk 0
- Select **Format the partition using the NTFS file system (Quick)** and press Enter
- Review regional and language options and click **Next**
- Enter Name and Organization
- Enter 25-character Volume License product key
- Licensing mode: Per server (5)
- Enter computer name and an Administrator password
- Confirm time settings
- Network Settings: Typical settings
- Select **No** and leave the workgroup name WORKGROUP
- At the login screen, eject the installation ISO for CD1
- Log in, then you are prompted for CD2
- Attach CD 2 then click OK
- Click Next then Next
- Click Finish (30 days for activation)
- Click Finish and Yes to allow inbound connections to the server

Testing:
- graphics really glitchy
- got IP address from OPNsense firewall OK
- http access "works" like http://icanhazip.com
- but a lot of things are broken like http://sethholcomb.com
- https things break because IE 6 is REALLY insecure
- 🌱 Does it work outside the pentesting lab?
