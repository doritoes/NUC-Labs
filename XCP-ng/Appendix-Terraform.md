# Appendix - Terraform and XCP-ng
References: https://github.com/vatesfr/terraform-provider-xenorchestra

IMPORTANT This Lab was originally built using XCP-ng 8.2, Check Point R81.20, and Windows 10/Server 2022. Updating to latest versions.

Updated Software Versions:
- XCP-ng 8.3
- Ubuntu 24.04
- XO commit fa020 and later
- Ansible core 2.16.3
- Terraform 1.13.5
- Windows 11
- Windows Server 2025
- Check Point R82

This appendix outlines building a complete lab designed for testing Check Point security products. It currently requires a <ins>lot</ins> of resources. My host for this Lab has 96GB of RAM, 22 CPUs, and 12TB of storage. A reduced version designed for 64GB of RAM might be in the future.
- 19 VMs
- 44 vCPUs (can over subscribe CPUs)
- 80 GB RAM
- 71 GB storage

Notes:
- Terraform integrates with the XO server, <ins>not</ins> the XCP-ng <ins>host</ins>
  - In contrast, the Ansible collection only integrates with the XCP-ng host
- Once built, the Windows 11 desktop systems can be used indefinitely, but the "Activate Windows" watermark will be present and personalization settings are disabled. There is no mandatory 30-day "grace period" anymore, as seen in older Windows versions. 
- Windows Servers have a standard 180 evaluation period
- Check Point systems have a 15-day trial by default (request a [30-day evaluation license](https://community.checkpoint.com/t5/General-Topics/How-to-Request-an-Evaluation-License-for-Security-Gateways-and/td-p/40391) as needed)
- Creating your original templates from "Other installation media" was required for Windows systems
  - 🌱 need to test if this is still an issue with XCP-ng 8.3
  - creating Windows systems from the built-in "Windows" templates fail to boot when created using Terraform
  - re-created the templates form "Other installation media" fixed the problem
  - Vates recommends avoiding using "Other installation media" for performance reasons; perhaps they will find a solution to this issue
- The are known issues with Identity Awareness
  - 🌱 The Identity Collector current version R82 sees to be required; it's not easily available from R81.20 systems. You might need a paid support account with Check Point, or try to grab from a R82 systems
  - You need to apply https://support.checkpoint.com/results/sk/sk26059

# Install Terraform
We are going to install Terrafrom on `ubuntu-xo`.

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
- Test
  - `terraform init`

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
  - When prompted, `reboot`, and confirm the reboot
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
- Confirm guest utilities
  - See [Appendix Build VyOS ISO with VMagents](Appendix_Build_VyOS_ISO_with_VM_agents.md) for instructions to build your own ISO with guest utilities; VyOS stopped shipping with them
  - `systemctl status xen-guest-agent`
- Convert `vyos-template` to template
  - `poweroff`
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm

## Create Check Point firewall Template
Here we will create a basic Check Point template suitable for an SMS or gateway (firewall).
- Log in to XO and create a Check Point firewall
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **checkpoint-template**
  - Description: **Check Point R82 template**
  - CPU: **4 vCPU**
    - A standalone gateway might run ok with 2 cores in some cases
  - RAM: **4GB**
    - SMS requires more; we will increase this later
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the Check Point R82 Gaia ISO image you uploaded to an ISO store*
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
  - Default gateway: **None** (it will auto fill; delete and leave blank)
  - <ins>NO</ins> DHCP server on the management interface
- Confirm you want to continue with formatting the drive **OK**
- When the message `Installation complete.` message appears
  - Press Enter
  - Wait for the system to start to reboot, then eject the ISO
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
      - `./install.sh -d rhel -m el8`
      - press `y`
      - `cd ..`
      - `rm LinuxGuestTools-8.4.0-1.tar.gz`
      - `rm -rf LinuxGuestTools-8.4.0-1`
    - `halt`
- Convert `checkpoint-template` to template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm that this can't be undone

NOTE The interface ip change change and setting the expert password were not saved, preserving the clean template.

## Create Windows 11 Template
🌱 NOTE Using "Other install media" isn't optimal, but is required because we are using Terraform

IMPORTANT Windows 11 will not install without a TPM

IMPORTANT If you want to set up using a local account instead of a Microsoft account:
- Disconnect Internet during setup
- https://www.elevenforum.com/t/clean-install-windows-11.99/
- The alternate method provided (Shift-F10 and enter OOBE\BYPASSNRO) didn't work in Lab testing
- This worked for Windows 11 Home or Pro
  - add second keyboard layout screen
    - Shift-F10
    - start ms-cxh:localonly
    - follow the Wizard
    - If the screen is black, wait a few minutes and reboot
    - Follow up with the skipping second keyboard layout

Steps:
- From the left menu click **New** > **VM**
  - Select the pool: **xcp-ng-lab1**
  - Template: **Other install media**
  - Name: **win11-template**
  - Description: **Windows 11**
  - CPU: **2 vCPU**
  - RAM: **4GB**
  - Topology: Default behavior
  - Install: ISO/DVD: *Select the Windows 11 iso you uploaded*
  - Interfaces: select **Pool-wide network associated with eth0** from the dropdown
  - Disks: Click **Add disk** and select **128GB** (Windows 11 minimum is 64GB; 128GB for lab, 256GB for average user)
  - Click **Create**
- The details for the new VM are now displayed
- Enable higher desktop resolution
  - Advanced tab > Enable VGA, set Video RAM to 16MiB
- Click **Console** tab
  - If you get prompted to press any key to boot from the CD or DVD, do so
    - if you missed it, restart the VM
  - Confirm Language, formats, and keyboard then **Next**
  - Select **Install Windows 11**, check the box, then click **Next**
  - Activate Windows: Click **I don't have a product key**
  - Select the OS to install: **Windows 11 Pro** (feel free to experiment)
  - WARNING You might get the error: This PC can't run Windows 11
    - "This PC doesn't meet the minimum requirements to install this version of Windows. For more information, visit https://aka.ms/WindowsSysReq"
    - Possible culprits: "Enable TPM 2.0 on your PC" (XCP-ng lists this as VTPM, virtual TPM)
  - Click **Accept**
  - Accept the installation on Drive 0, click **Next**
  - Click **Install**
  - Wait while the system reboots and gradually installs
  - Set region click **Yes**
  - Accept keyboard and click **Yes**
  - At the second keyboard layout screen, STOP, and follow these steps if you haven't "broken" the Internet connection
    - Press shift-F10 to open a command prompt
    - `start ms-cxh://setaddlocalonly`
    - See also: `reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v BypassNRO /t REG_DWORD /d 1 /f`
    - Follow prompts to add a local user, password, and security options
    - This ends at a blank screen. Wait for a minute and it will return.
    - Reboot the VM from XCP-ng
  - Disable all privacy settings and click Next
  - Your device will have a DESKTOP-xxxxxxx name
  - If you chose to break the network connectivity insteady of bypassing the account creation
    - Select Set up for personal use (feel free to experiment)
    - Disconnect from the Internet and start over
      - Option 1 - power down the VyOS router for a while
      - Option 2 - edit the VM's network device and check Disconnect for now; uncheck it later
    - At *Lets's connect you to a network*
      - Click **I don't have internet**
    - Click **Continue with limited setup**
    - User: **lab**
    - Password: *select a password*
    - Create security questions for this account: be creative
    - Privacy: disable all the settings and then click Next (or might be Accept)
  - and keyboard layout, skip second keyboard layout
- Log in
- Reconnect to the Internet as needed
- Eject the installation ISO
- Install Guest Tools
  - The Windows tools are not included on the guest-tools.iso
  - Download from https://www.xenserver.com/downloads
    - XenServer VM Tools for Windows 9.4.2 > Download XenServer VM Tools for Windows
    - Download .msi file and install manually (or install later using group policy)
    - Permit the reboot and log back in
      - Message confirming tools installed is displayed
    - Delete the downloaded file when done
    - Edge settings: Don't bring over data, Continue without Google data, don't "Make your Microsoft experience more useful to you", Confirm and start browsing, close customization window
- Apply Windows Updates (reboots included)
- Optionally, [debloat Windows 11](Appendix-Debloat-Windows11.md)
  - Copy and paste the below command into PowerShell
  - `& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))`
- Optionally disable Windows Update Delivery Optimization to remove strange looking traffic from your logs
  - Start > Settings > Update & Security > Windows Update > Advanced options > Delivery Optimization
  - Turn off Allow downloads from other devices
- Optionally clear all browser settings (including history) by deleting the default profile
  - Open Edge
  - Settings > Settings
  - Click the trash can next to **Profile 1** and then click **Remove profile**
  - Close Edge
- Enable Remote Desktop (RDP)
  - **Start** > **Settings** > **System** > **Remote Desktop**
  - Slide to enable and Confirm
- Optional
  - increase the display resolution: [Appendix - Display Resolution](Appendix-Display_Resolution.md)
  - clean up the taskbar, desktop, etc. to meet your preferences
  - set the correct timezone
- Change the hostname to **win11-template**
  - From administrative powershell: `Rename-Computer -NewName win11-template`
- Shut down the Windows VM
  - `stop-computer`
- Convert `win11-template` to a template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm

## Create Windows Server 2025 Template
🌱 NOTE Using "Other install media" isn't optimal, but is required because we are using Terraform

NOTE These steps do not create a virtual TPM. Without a VTPM some enhanced security features like bitlocker are not available.

NOTE This is a bare-bones server with limited resources. Images created from this template can given more resources.

Steps:
- From the left menu click **New** > **VM**
  - Select the pool **xcp-ng-lab1**
  - Template: **Windows Server 2025**
  - Name: **server2025-template**
  - Description: **Windows Server 2025**
  - CPU: **1 vCPU** (will peg the CPU a lot; if you need better response add a vCPU)
  - RAM: **2GB**
  - Topology: Default behavior
  - Install: ISO/DVD: *Select the Windows Server 2025 evaluation iso you uploaded*
  - Interfaces: select **Pool-wide network associated with eth0**
  - Disks: Click **Add disk** and select **64GB** (default)
  - Click **Create**
- The details for the new VM are now displayed
- Enable higher desktop resolution
  - Advanced tab > Enable VGA, set Video RAM to **16MiB**
- Click **Console** tab
- If prompted **Press any key to boot from CD to DVD...**, do so
  - If you missed it, power cycle and try again
- Follow the Install wizard per usual
  - Confirm Language and formats then **Next**
  - Confirm keyboard then **Next**
  - Confirm **Install Windows Server**, check the box, then **Next**
  - Select the OS to install: **Windows Server 2025 Standard Edition Evaluation (Desktop Experience)**
    - feel free to experiment
  - Click **Accept**
  - Accept the installation on Drive 0, **Next**
  - Click **Install**
- Wait patiently for Windows Server to install - "Your PC will restart several times. This might take a while."
- Customize settings
  - Set password for user `Administrator`
- Disconnect the ISO
- Login in
  - The small keyboard icon allows you to send a Ctrl-Alt-Delete
  - Yes, allow the server to be discovered by other hosts on the network
- Send diagnostic data to Microsoft: Required only then Accept
- Install Guest Tools
  - The Windows tools are not included on the guest-tools.iso
  - Download from https://www.xenserver.com/downloads
    - XenServer VM Tools for Windows 9.4.2 > Download XenServer VM Tools for Windows
  - Download MSI and install manually (or install later using group policy)
    - Accept the reboot; upon logging back in note the confirmation
    - Remove the downloaded file when done
- Apply Windows Updates (reboots required)
  - Note that at some boots, certain services are on a delayed start, impacting the updates
- Enable RDP
  - Start > Settings > System > Remote Desktop
  - Slide to Enable Remote Desktop then accept the message
- Optionally, increase the display resolution: [Appendix - Display Resolution](Appendix-Display_Resolution.md)
- Optionally, set the correct timezone
- Change the hostname to server2025-template
  - From administrative powershell: `Rename-Computer -NewName server2025-template`
- Reboot the computer
  - `restart-computer`
- Now let's prepare the template VM for cloning
  - must perform generalization to remove the security identifier (SID)
  - allows us to rapidly clone more servers
  - Open an administrative CMD or powershell window
    - `cmd /k %WINDIR%\System32\sysprep\sysprep.exe /oobe /generalize /shutdown`
- Convert `server2025-template` to template
  - Click the **Advanced** tab
  - Click **Convert to template** and confirm

## Create Ubuntu Server 24.04 LTS Template
- From the left menu click **New** > **VM**
  - Select the pool: **xcp-ng-lab1**
  - Template: **Ubuntu Noble Numbat 24.04**
  - Name: **ubuntu-server-template**
  - Description: **Ubuntu Server 24.04**
  - CPU: **1 vCPU**
  - RAM: **2GB**
  - Topology: Default behavior
  - Install: ISO/DVD: **Select the Ubuntu 24.04 Server image you uploaded**
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
  - Check the box **Install OpenSSH server**
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
    - Optionally set the pretty name: `sudo hostnamectl set-hostname "Ubuntu Server 24.04" --pretty`
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
