# Connect ISO Storage
When we converted from the XOA appliance to the community edition of XO, we "lost" the Hub's pre-populuated templates and ISO management. In this step we will prepare to build our VMs by first creating a place to store the ISO images.

References: https://www.youtube.com/watch?v=vuYvyD0GoBQ
# File Share
## Create File Share
Your have some options here. If you have a NAS, you can share a folder and optionally enable NFS. Otherwise, create a SMB share (shared folder) on your PC or server.

## Copy ISOs to File Share
As of this writing, here the templates in XO, and links to ISOs. And yes, if your OS doesn't have a template you will choose "Other Install Media".
- AlmaLinux - https://almalinux.org/get-almalinux/
  - AlmaLinux 8 and 9
  - Be aware there are 3 types of ISO
- CentOS - https://www.centos.org/download/
  - CentOS Linux 7 EOL: 2024-06-30
  - CentOS Linux 8 EOL: 2021-12-31
  - CentOS Stream 8 EOL: 2024-05-31
  - CentOS Stream 9 EOL: 2027-05-31
- CoreOS - https://fedoraproject.org/coreos/download?stream=stable
  - Fedora CoreOS has 3 release streams; use Stabe Live DVD iso
- Debian - https://www.debian.org/download - https://www.debian.org/CD/ - https://www.debian.org/releases/
  - Debian 12 Cloud-init (Hub)
  - Debian Bookworm 12
  - Debian Bullseye 11
  - Debian Stretch 9.0
  - Debian Jessie 8.0
  - Download older images: https://cdimage.debian.org/mirror/cdimage/archive/
- Gooroom Platform 2.0 - https://github.com/gooroom
  - Gooroom Platform is a Linux distribution and basic operating system (OS) developed in South Korea to support cloud-based work environments for public institutions.
- NeoKylin Linux Server 7 - based on RHEL
- Oracle Linux - https://yum.oracle.com/oracle-linux-isos.html
- Oracle Linux 7, 8, 9
- Red Hat Enterprise Linux (RHEL) - 
  - Need to start a trial or have subscription to access the download page
  - Red Hat Enterprise Linux 8 and 9
- Rocky Linux - https://rockylinux.org/download
  - Rocky Linux 8, 9
  - open source Linux designed to be compatible with RHEL
- SUSE Enteprise Linux - https://www.suse.com/products/
- Scientific Linux 7
  - SL is EOL, and Alma was chosen in its stead
- Ubuntu https://ubuntu.com/download
  - Ubuntu 20.04 Cloud-Init 71
  - Ubuntu Bionic Beaver 18.04
  - Ubuntu Focal Fossa 20.04
  - Ubuntu Jammy Jellyfish 22.04
  - Ubuntu Xenial Xerus 16.04
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

## Connect XCP-ng to File Share
1. Log in to XO
2. From the left menu, click New > Storage
    - Host: xcp-ng-lab1
    - Name: ISO
    - Description: installation media
    - Select storage type:
      - ISO SR - SMB ISO
        - This is a file share on your NAS or your PC
        - Enter the UNC (example \\server\sharename\)
          - If DNS isn't resolving, use the IP address of the server
        - Enter username and password
        - Click Create
      - ISO SR - NFS ISO
        - This is an NFS mount your NAS or a server
        - Enter the server IP
        - Click the magnifying glass (populate the path dropdown)
        - select the path (will auto populate)
        - Click Create


# Local ISO Respository on XO Server
We will also demonstrate storing .iso files on the XCP-ng host, which you might want to avoid--it uses up storage on our host.

See references: https://xcp-ng.org/blog/2022/05/05/how-to-create-a-local-iso-repository-in-xcp-ng/

1. Log in to XO
2. From the left menu, click New > Storage
    - Host: xcp-ng-lab1
    - Name: LOCAL-ISO
    - Description: installation media
    - Select storage type:
      - ISO SR - Local
      - Path: /media
    - Click Create
3. From left menu, click Import > Disk
4. Select your freshly crated ISOs SR
5. Drag and drop your ISOs to upload them to the XO
