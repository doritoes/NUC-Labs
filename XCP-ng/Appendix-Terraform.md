# Appendix - Terraform and XCP-ng
References: https://github.com/vatesfr/terraform-provider-xenorchestra

This appendix outlines building a complete lab designed for testing Check Point security products. It currently requires a <ins>lot</ins> of resources. My host for this Lab has 96GB of RAM, 22 CPUs, and 12TB or storage. A reduced version designed for 64GB of RAM might be in the future.
- 19 VMs
- 44 vCPUs (can over subscribe CPUs)
- 80 GB RAM
- 71 GB storage

Notes:
- Terraform integrates with the XO server, <ins>not/ins> the XCP-ng <ins>host</ins>
- Once built, the Windows 10 desktop systems have a month to operate without activation
  - Some personalization features in Windows Settings are disabled if you don’t activate (cannot change desktop wallpapers, windows colors and themes, customize Start menu/taskbar/lock screen/title bar/fonts, etc.)
  - Without activation, Windows may only download critical updates; some updates like optional updates, drivers, or security updates may be missed
- Windows Servers have a standard 180 evaluation period
- Check Point systems have a 15-day trial by default (request a [30-day evaluation license](https://community.checkpoint.com/t5/General-Topics/How-to-Request-an-Evaluation-License-for-Security-Gateways-and/td-p/40391) as needed)
- Creating your original templates from "Other installation media" was required for Windows systems
  - creating Windows systems from the built-in "Windows" templates fail to boot when created using Terraform
  - re-created the templates form "Other installation media" fixed the problem
  - Vates recommends avoiding using "Other installation media" for performance reasons; perhaps they will find a solution to this issue
- The are known issues with Identity Awareness
  - The Identity Collector current version R82 sees to be required; it's not easily available from R81.20 systems. You might need a paid support account with Check Point, or try to grab from a R82 systems
  - You need to apply https://support.checkpoint.com/results/sk/sk26059

# Install Terraform
This can be run from another host in your Lab, such as WSL on a Windows desktop. You might eventually move it to the Windows management workstation we will set up later.

- Install prerequisites
  - `sudo apt-get update && sudo apt-get install -y lsb-release gnupg software-properties-common`
- Quick install
~~~
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee -a  /etc/apt/sources.list.d/terraform.list
sudo apt update && sudo apt install -y terraform
~~~
- Confirm
  - `terraform -v`

# Set up Project
- Create project directory
  - `mkdir ~/terraform`
  - `cd ~/terraform`
- Create file provider.tf from [provider.tf](terraform/provider.tf)
- Create file credentials.auto.tfvars from [credentials.auto.tfvars](terraform/credentials.auto.tfvars)
  - Modify to use your XCP-ng host IP address
  - Modify to use a valid username and password

# Create Templates
## Create VyOS Template
- Log in to XO and create a VyOS router
- From left menu **New** > **VM**
  - Pool: **xcp-ng-lab1**
  - Template: **Other install media**
  - Name: **vyos-template**
  - Description: **vyos-template**
  - CPU: **2 vCPU**
  - RAM: **1GB**
  - Topology: **Default behavior**
  - Install: ISO/DVD: *Select the VyOS ISO image you uploaded earlier*
  - Interfaces:
    - First interface: *Pool-wide network associated with eth0*
  - Disks: Click Add disk
    - **8GB**
  - Click **Create**
- Click **Console** tab and access the console
- Install the Image
  - Login: `vyos`/`vyos`
  - `install image`
  - Allow installation to continue with default values
  - When you are asked to set the password just use `vyos`
  - When prompted, `reboot`
  - After the reboot starts, eject the VyOS iso
- Log back in (`vyos`/`vyos`)
- Add user `ansible` for management
  - `configure`
  - `set system login user ansible full-name "ansible management"`
  - `set system login user ansible authentication plaintext-password examplepassword`
    - The old permissions system has been removed
      - Gone: `set system login user ansible level admin`
      - All accounts now have sudo permissions
  - `commit`
  - `save`
  - `exit`
- Enable guest utilities
  - `sudo systemctl start xe-guest-utilities`
  - `sudo systemctl enable xe-guest-utilties`
  - `poweroff`
- Convert `vyos-template` to template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm

## Create Check Point firewall Template
Here we will create a basic Check Point template suitable for an SMS or gateway (firewall).
- Log in to XO and create a Check Point firewall
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **checkpoint-template**
  - Description: **Check Point R81.20 template**
  - CPU: **4 vCPU**
    - A standalone gateway might run ok with 2 cores in some cases
  - RAM: **4GB**
    - SMS requires more; we will increase this later
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the Check Point Gaia ISO image you uploaded*
  - Interfaces:
    - Network: from the dropdown select the **pool-wide network associated with eth0**
  - Disks: Click **Add disk**
    - Add **128GB** disk
  - Click **Create**
- The details for the new Check Point VM are now displayed
- Click the **Network** tab
  - Next to each interface (one in this case) is a small settings icon with a blue background
  - Click the gear icon then <ins>disable TX checksumming</ins>
- Click **Console** tab and watch as the system boots to a menu
- At the boot menu, select **Install Gaia on this system**
- Accept the installation message **OK**
- Confirm the keyboard type
- Accept the default partitions sizing for 128GB drive
  - Swap: 7GB (6%)
  - Root: 20GB (16%)
  - Logs: 20GB (16%)
  - Backup and upgrade: 79GB (62%)
  - Feel free to customize
  - Choose **OK**
- Select a password for the "admin" account
- Select a password for <ins>maintenance mode "admin" user</ins>
- Select **eth0** as the management port
  - IP address: **192.168.41.254**
  - Netmask: **255.255.255.0**
  - Default gateway: **None** (it will auto feel; delete and leave blank)
  - <ins>NO</ins> DHCP server on the management interface
- Confirm you want to continue with formatting the drive **OK**
- When the message `Installation complete.` message appears
  - Press Enter
  - Wait for the system to start to reboot, then eject the iso
- Log in from the Console
  - user `admin` and the password you configured
- `set hostname CPTEMPLATE`
- Set up ansible user
  - Reference [link](https://sc1.checkpoint.com/documents/R81.20/WebAdminGuides/EN/CP_R81.20_Gaia_AdminGuide/Content/Topics-GAG/Configuring-SSH-Authentication-with-RSA-Key-Files.htm)
  - `add user ansible uid 0 homedir /home/ansible`
  - `set user ansible password`
  - `add rba user ansible roles adminRole`
  - `set user ansible shell /bin/bash`
  - `save config`
- Install guest tools
  - Select an IP address on your Lab network for temporary use
    - Example: 192.168.1.130
  - Change the interface IP to that address
    - `set interface eth0 ipv4-address 192.168.1.130 mask-length 24`
  - Set the user shell to bash
    - `set expert-password`
      - select a password for "expert mode"
    - `expert`
      - enter the password when prompted
    - `chsh -s /bin/bash admin`
  - From a Windows machine in your Lab
    - Download VM Tools for Linux from https://www.xenserver.com/downloads
    - Point WinSCP to the device: For example, 192.168.1.130
    - Username: admin
    - Password: the password you selected
    - Accept the warnings
    - Drag file (i.e., LinuxGuestTools-8.4.0-1.tar.gz) file to the Check Point device's `/home/admin` folder
    - Close WinSCP
  - From XO with console the Check Point template device
    - Revert to clish shell
      - `chsh -s /etc/cli.sh admin`
    - Install guest tools
      - `tar xzvf LinuxGuestTools-8.4.0-1.tar.gz`
      - `cd LinuxGuestTools-8.4.0-1`
      - `./install.sh -d rhel -m el7`
      - press `y`
      - `cd ..`
      - `rm LinuxGuestTools-8.4.0-1.tar.gz`
      - `rm -rf LinuxGuestTools-8.4.0-1`
    - `halt`
- Convert `checkpoint-template` to template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm that this can't be undone

NOTE The interface change and setting expert password were not saved, preserving the clean template.

## Create Windows 10 Template
NOTE Using "Other install media" isn't optimal, but is required because we are using Terraform
- From the left menu click **New** > **VM**
  - Select the pool: **xcp-ng-lab1**
  - Template: **Other install media**
  - Name: **win10-template**
  - Description: **Windows 10**
  - CPU: **2 vCPU**
  - RAM: **4GB**
  - Topology: Default behavior
  - Install: ISO/DVD: *Select the Windows 10 iso you uploaded*
  - Interfaces: select **Pool-wide network associated with eth0** from the dropdown
  - Disks: Click **Add disk** and select **128GB**
  - Click **Create**
- The details for the new VM are now displayed
- Optionally enable higher desktop resolution
  - Advanced tab > Enable VGA, set Video RAM to 16MiB
- Click **Console** tab
- If you are prompted to press any key to boot from CD or DVD
  - **Press any key**
  - If you missed it, power cycle and try again
- Follow the Install wizard per usual
  - Confirm Language, formats, and keyboard then **Next**
  - Click **Install now**
  - Activate Windows: Click **I don't have a product key**
  - Select the OS to install: **Windows 10 Pro** (feel free to experiment) and **Next**
  - Check the box then click **Next**
  - Click **Custom: Install Windows only (advanced)**
  - Accept the installation on Drive 0, click **Next**
  - Wait while the system reboots and gradually installs
  - Set region and keyboard layout, skip second keyboard layout
  - Select **Set up for personal use** (feel free to experiment)
  - Click **Offline account** then click **Limited experience**
  - User: **lab**
  - Password: *select a password*
  - Create security questions for this account (*be creative*)
  - Click **Not now**
  - Privacy: *disable all the settings* and then click **Accept**
  - Experience: be creative and pick one, then click **Accept** (I chose Business)
  - Cortana: click **Not now**
  - At the desktop, open the Edge browser
    - Click **Complete setup**
    - Click **Continue without signing in**
- Install Guest Tools
  - The Windows tools are not included on the guest-tools.iso
  - Download from https://www.xenserver.com/downloads
    - XenServer VM Tools for Windows 9.3.3 > Download XenServer VM Tools for Windows
    - Download .msi file and install manually (or install later using group policy)
    - Permit the reboot and log back in
      - Message confirming tools installed is displayed
    - Delete the downloaded file when done
- Apply Windows Updates (reboots included)
- Optionally disable Windows Update Delivery Optimization to remove strange looking traffic from your logs
  - Start > Settings > Update & Security > Windows Update > Advanced options > Delivery Optimization
  - Turn off Allow downloads from other PCs
- Optionally clear all browser settings (including history) by deleting the default profile
  - Open Edge
  - Settings > Settings
  - Click the trash can next to **Profile 1** and then click **Remove profile**
  - Close Edge
- Optionally enable higher desktop resolution
  - Advanced tab > Enable VGA, set Video RAM to 16MiB
  - Will be able to set to higher resolutions after reboot
- Eject the installation ISO
- Enable Remote Desktop (RDP)
  - **Start** > **Settings** > **System** > **Remote Desktop**
  - Slide to enable and Confirm
- Optional
  - increase the display resolution: [Appendix - Display Resolution](Appendix-Display_Resolution.md)
  - clean up the taskbar, desktop, etc. to meet your preferences
  - set the correct timezone
- Change the hostname to **win10-template**
  - From administrative powershell: `Rename-Computer -NewName win10-template`
- Shut down the Windows VM
  - `stop-computer`
- Convert `win10-template` to a template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm

## Create Windows Server 2022 Template
This is a bare-bones server with limited resources. Images created from this template can given more resources.

NOTE Using "Other install media" isn't optimal, but is required because we are using Terraform

- From the left menu click **New** > **VM**
  - Select the pool **xcp-ng-lab1**
  - Template: **Other install media**
  - Name: **server2022-template**
  - Description: **Windows Server 2022**
  - CPU: **1 vCPU** (will peg the CPU a lot; if you need better response add a vCPU)
  - RAM: **2GB**
  - Topology: Default behavior
  - Install: ISO/DVD: *Select the Windows Server 2022 evaluation iso you uploaded*
  - Interfaces: select *Pool-wide network associated with eth0*
  - Disks: Click **Add disk** and select **128GB**
  - Click **Create**
- The details for the new VM are now displayed
- Optionally enable higher desktop resolution
  - Advanced tab > Enable VGA, set Video RAM to 16MiB
- Click **Console** tab
- If you are prompted to Press any key to boot from CD to DVD
  - **Press any key**
  - If you missed it, power cycle and try again
- Follow the Install wizard per usual
  - Confirm Language, formats, and keyboard then **Next**
  - Click **Install now**
  - Select the OS to install: **Windows Server 2022 Standard Edition Evaluation (Desktop Experience)**
    - feel free to experiment
  - Check the box then click **Next**
  - Click Custom: **Install Windows only (advanced)**
  - Accept the installation on Drive 0
- Set password for user `Administrator`
- Disconnect the ISO
- Login in
  - The small keyboard icon allows you to send a Ctrl-Alt-Delete
  - Yes, allow the server to be discovered by other hosts on the network
- Install Guest Tools
  - The Windows tools are not included on the guest-tools.iso
  - Download from https://www.xenserver.com/downloads
    - XenServer VM Tools for Windows 9.3.3 > Download XenServer VM Tools for Windows
  - Download MSI and install manually (or install later using group policy)
    - Accept the reboot; upon logging back in note the confirmation
    - Remove the downloaded file when done
- Apply Windows Updates (reboots required)
  - Note that at some boots, certain services are on a delayed start, impacting the updates
- Optionally clear all browser settings (including history) by deleting the default profile
  - Open Edge
  - Settings > Settings
  - Click the trash can next to **Profile 1** and then click **Remove profile**
  - Close Edge
- Optionally enable higher desktop resolution
  - Advanced > Enable VGA, set Video RAM to 16MiB
- Enable RDP
  - Start > Settings > System > Remote Desktop
  - Slide to Enable Remote Desktop then accept the message
- Optionally, increase the display resolution: [Appendix - Display Resolution](Appendix-Display_Resolution.md)
- Optionally, set the correct timezone
- Change the hostname to server2022-template
  - From administrative powershell: `Rename-Computer -NewName server2022-template`
- Reboot the computer
  - `restart-computer`
- Now let's prepare the template VM for cloning
  - must perform generalization to remove the security identifier (SID)
  - allows us to rapidly clone more servers
  - Open an administrative CMD or powershell window
    - `cmd /k %WINDIR%\System32\sysprep\sysprep.exe /oobe /generalize /shutdown`
- Convert `server2022-template` to template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm

## Create Ubuntu Server 22.04 LTS Template
- From the left menu click **New** > **VM**
  - Select the pool: **xcp-ng-lab1**
  - Template: **Other install media**
  - Name: **ubuntu-server-template**
  - Description: **Ubuntu Server 22.04**
  - CPU: **1 vCPU**
  - RAM: **2GB**
  - Topology: Default behavior
  - Install: ISO/DVD: **Select the Ubuntu 22.04 Server image you uploaded**
  - Interfaces: select **Pool-wide network associated with eth0**
  - Disks: Click **Add disk** and select **20GB**
  - Click **Create**
- The details for the new VM are now displayed
- Click the **Console** tab and follow the Install wizard per usual  
  - READ CAREFULLY the Guided storage configuration
    - Root / only has **10GB** of the **20GB** allocated
    - Solutions (if in doubt, use Option 1; Option 2 is popular for /var, /var/log, /opt, or /home)
      - Option 1 expand root /
        - Under used devices, locate ubuntu-lv which will be mounted at root /
        - Select it, and then Edit
        - Change the Size to the max value
      - Option 2
        - Select the free space, then Create Logical Volume
        - Adjust the size to use the free space
        - Adjust the mount point (/home by default)
  - Check **Install OpenSSH server**
  - Do not select any snaps
- To remove the installation media, click the Eject icon
- Press Enter to Reboot
- Log in to the console and check the system
  - `df -h`
- Install guest tools
  - Connect the guest-tools.iso (select it from the dropdown)
  - Log in to the console
  - Mount the guest tools iso
    - `sudo mount /dev/cdrom /media`
    - `cd /media/Linux`
  - Install the tools
    - `sudo ./install.sh`
    - you may be prompted to enter your password
    - you are prompted accept the change
    - you are reminded to reboot
  - Unmount the guest tools iso
    - `cd ~`
    - `sudo umount /media`
  - `sudo reboot`
  - Eject guest-tools.iso
- Add ansible user
  - `sudo useradd ansible -s /bin/bash -g sudo -m`
  - `sudo passwd ansible`
- Give permissions to user ansible
  - `echo "ansible ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/dont-prompt-ansible-for-sudo-password`
- Update the VM
  - Updates
    - `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`
    - accept the messages (default values OK)
  - Change hostname
    - View current hostname: `hostnamectl`
    - Set the new hostname: `sudo hostnamectl set-hostname ubuntu-server-template`
    - Optionally set the pretty name: `sudo hostnamectl set-hostname "Ubuntu Server 22.04" --pretty`
    - Confirm it has changed: `hostnamectl`
- Power down VM
  - `poweroff`
- Convert `ubuntu-server-template` to template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm that this can't be undone

# Create Lab Environment
## Network Configuration
- Create file network.tf from [network.tf](terraform/network.tf)
- `terraform init`
- `terraform plan`
- `terraform apply -auto-approve`
- Log in to XO and confirm the new networks are created
- Destroy and re-create
  - `terraform destroy`
  - `terraform apply -auto-approve`

## Create VyOS Router with Terraform
- Create file network.tf from [router.tf](terraform/router.tf)
- `terraform plan`
- `terraform apply -auto-approve`

## Create Check Point firewalls with Terraform
- Create file firewalls.tf from [firewalls.tf](terraform/firewalls.tf)
- `terraform plan`
- `terraform apply -auto-approve`

## Create Workstations
- Create file workstations.tf from [workstations.tf](terraform/workstations.tf)
- `terraform plan`
- `terraform apply -auto-approve`

## Create Servers
- Create file servers.tf from [servers.tf](terraform/servers.tf)
- `terraform plan`
- `terraform apply -auto-approve`

# Next Steps
At this point we are are done with using terraform.
Continue Lab set up with [Prep for Ansible and Complete FTW Configuration](Appendix-Ansible.md)
