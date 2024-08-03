# Appendix - Terraform and XCP-ng
References: https://github.com/vatesfr/terraform-provider-xenorchestra

Notes:
- Terraform integrates with the XO server, not the XCP-ng host

# Install Terrafrom
This can be run from another host in your Lab, such as WSL on a Windows desktop.

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
- Create file demo.tf from [demo.tf](terraform/demo.tf)
- Test
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
- The output shows
  - number of VMs that are running (vms_length)
  - sum of all running VMs' max memory in bytes (vms_max_memory_map)

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
- Open Console
- Install the Image
  - Login: `vyos`/`vyos`
  - `install image`
  - Allow installation to continue with default values
  - When you are asked to set the password just use `vyos`
  - When promted, `reboot`
  - After the reboot starts, eject the VyOS iso
- Enable guest utilties
  - Log back in
    - `sudo systemctl start xe-guest-utilities`
    - `sudo systemctl enable xe-guest-utilties`
    - `poweroff`
- Convert to Template
  - Click the Advanced tab
  - Click Convert to template and confirm that this can't be undone

## Create Check Point firewall Template
Here we will 
- Log in to XO and create a Check Point firewall
- From the left menu click **New** > **VM**
  - Select the pool **xcgp-ng-lab1**
  - Template: **Other install media**
  - Name: **checkpoint-template**
  - Description: **R81.20 Check Point template**
  - CPU: **4 vCPU**
    - A standalone gateway might run ok with 2 cores in some cases
  - RAM: **4GB**
    - SMS reqires more; we will increase this later
  - Topology: *Default behavior*
  - Install: ISO/DVD: *Select the Check Point Gaia ISO image you uploaded*
  - First Interface:
    - Network: from the dropdown select the **pool-wide network associated with eth0**
    - This is replaced by the specific interfaces required
  - Disks: Click **Add disk**
    - Add **128GB** disk
  - Click **Create**
- The details for the new Check Point VM are now displayed
- Click the **Network** tab
  - Next to each interface is a small settings icon with a blue background
  - For every interface click the gear icon then <ins>disable TX checksumming</ins>
- Click **Console** tab and watch as the system boots
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
  - IP address: **192.168.31.254**
  - Netmask: **255.255.255.0**
  - Default gateway: **192.168.31.1**
  - <ins>NO</ins> DHCP server on the management interface
- Confirm you want to continue with formatting the drive **OK**
- When the message `Installation complete.` message appears
  - Press Enter
  - Wait for the system to start to reboot, then eject the iso
- Log in from the Console
- `set hostname CPTEMPLATE`
- `save config`
- Install guest tools
  - Select and IP address on your Lab network for temporary use
    - Example: 192.168.1.130
  - Change the interface IP to that address
    - `set interface eth0 ipv4-address 192.168.1.0 mask-length 24`
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
    - 🌱Add SSH keys for Ansible management
    - Install guest tools
      - `tar xzvf LinuxGuestTools-8.4.0-1.tar.gz`
      - `cd LinuxGuestTools-8.4.0-1`
      - `./install -d rhel -m el7`
      - press `y`
      - `rm LinuxGuestTools-8.4.0-1.tar.gz && rm -rf LinuxGuestTools-8.4.0-1`
    - `halt`
- Click the **Advanced** tab
- Click **Convert to template**

NOTE The interface change and setting expert password were not saved, preserving the clean template.

# Create Lab Environment
## Network Configuration
- Create file network.tf from [network.tf](terraform/network.tf)
- `terraform init`
- `terraform plan`
- `terraform apply -auto-approve'
- Log in to XO and confirm the new neworks are created
- Destroy and re-create
  - `terraform destroy`
  - `terraform apply -auto-approve`

## Create VyOS Router with Terraform
- Create file network.tf from [router.tf](terraform/router.tf)
- `terraform plan`
- `terraform apply -auto-approve'

## Create Check Point firewalls with Terraform
- Create file firewalls.tf from [firewalls.tf](terraform/firewalls.tf)
- `terraform plan`
- `terraform apply -auto-approve'
