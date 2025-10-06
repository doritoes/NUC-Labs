# Connect ISO Storage

# File Share
## Create File Share
Your have some options here. If you have a NAS, you can share a folder and optionally enable NFS. Otherwise, create a SMB share (shared folder) on your PC or server.

## Copy ISOs to File Share
Here are some commonly used ISOs ans where to find them.
- AlmaLinux - https://almalinux.org/get-almalinux/
  - AlmaLinux 8, 9, and 10
  - Be aware there are 3 types of ISO
- CentOS - https://www.centos.org/download/
  - CentOS Linux 7 EOL: 2024-06-30
  - CentOS Linux 8 EOL: 2021-12-31
  - CentOS Stream 8 EOL: 2024-05-31
  - CentOS Stream 9 EOL: 2027-05-31
  - CentOS Stream 10 EOL: 2030-05-31
- CoreOS - https://fedoraproject.org/coreos/download?stream=stable
  - Fedora CoreOS has 3 release streams; use Stable Live DVD iso
- Debian - https://www.debian.org/download - https://www.debian.org/CD/ - https://www.debian.org/releases/
  - Debian 13
  - Download older images: https://cdimage.debian.org/mirror/cdimage/archive/
- Gooroom Platform 2.0 - https://github.com/gooroom
  - Gooroom Platform is a Linux distribution and basic operating system (OS) developed in South Korea to support cloud-based work environments for public institutions.
- Kali Linux - https://www.kali.org/get-kali/#kali-platforms
  - Kali Linux
  - Kali Purple Linux
- Oracle Linux - https://yum.oracle.com/oracle-linux-isos.html
  - Oracle Linux 7, 8, 9, 10
- Red Hat Enterprise Linux (RHEL) - 
  - Need to start a trial or have subscription to access the download page
  - Red Hat Enterprise Linux 8 and 9
- Rocky Linux - https://rockylinux.org/download
  - Rocky Linux 8, 9
  - open source Linux designed to be compatible with RHEL
- SUSE Enterprise Linux - https://www.suse.com/products/
  - purchase required
- Ubuntu https://ubuntu.com/download
  - Ubuntu 24.04 LTS
  - Ubuntu 25.04 "latest", little support
- Windows
  - Windows 10 - https://www.microsoft.com/en-us/software-download/windows10 and https://www.tenforums.com/tutorials/9230-download-windows-10-iso-file.html
  - Windows 11 - no template, but see here: https://www.microsoft.com/software-download/windows11
  - Windows 8.1 - EOL, not publicly available
  - Windows Server
    - [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/)
    -  Register, then download and install. (Note: This evaluation edition expires in 180 days) 
    - From top menu click Windows Server > Windows Server and select the desired version
      - Click Download the ISO - <ins>Registration required</ins>
      -  Goes back to Server 2016
    -  See also https://gist.github.com/vinhjaxt/a774ac87b0313a34f4c445048d8e13cf
- OPNsense - https://opnsense.org/download/
  - OPNSense 25.7
- pfSense - https://www.pfsense.org/download/
  - "The installer is free but uses the Netgate Store to handle the download process."
- VyOS - https://vyos.net/get/

## Connect Proxmox VE to File Share
### File Share (SMB/CIFS)
- From the left pane click **Datacenter**
- Click **Storage** and then click **Add** > **SMB/CIFS**
- ID: **ISO-SMB**
- Server: `<IP_Address of computer/NAS>`
- Username: *user authorized to access the share*
- Password: *the password for that user*
- Share: *the name of the share*
- Enable: **Checked**
- Content: **ISO image** (only)
- Click **Add**

IMPORTANT This will create a subdirectory "template" and inside that the "iso" directory
- Copy your ISOs inside this "iso" location to be accessible from proxmox

### NFS
REMEMBER your NFS server (NAS) may require you to add the proxymox host's IP address to its permissions
- From the left pane click **Datacenter**
- Click **Storage** and then click **Add** > **NFS**
- ID: **ISO-NFS**
- Server: `<IP_Address of NAS>`
- Export: *click the down arrow* (e.g., `/volume1/ISO`)
- Content: **ISO image** (only)
- Enable: **Checked**
- Click **Add**

IMPORTANT This will create a subdirectory "template" and inside that the "iso" directory
- Copy your ISOs inside this "iso" location to be accessible from proxmox

# Local ISO Repository on proxmox Host
We will also demonstrate storing .iso files on the proxmox host, which you might want to avoid--it uses up storage on our host.

1. Log in to proxmox
2. From the left menu, expand **Datacenter** > **proxymox-lab** > **local (proxmox-lab)**
3. Click **ISO Images**
4. Click **Upload**
5. Select the ISO file to upload, and click **Upload**
