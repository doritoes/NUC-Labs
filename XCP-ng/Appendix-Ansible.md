# Appendix - Ansible Configuring Check Point Lab
This appendix follows the next steps after completing [Appendix - Terraform and XCP-ng](Appendix-Terraform.md). Now that the VMs are created, it's time to prepare them for the next step, configuring and managing using Ansible.

Notes:
- The Linux-based VM templates have the user `ansible` created. SSH with RSA keys still needs to be enabled.

# Build the Environment using Terraform
- `terraform plan`
- `terraform apply -auto-approve`

# Configure Management Workstation
- From XO, click on `mananger`
  - Note the network is configured for two interfaces
    - First one: `Pool-wide network associated with eth0`
      - allows downloading and installing software and packages
      - will be desabled after Branch 1 configuration is complete, or completely removed
    - Second one: `branch1mgt`
- Optionally, from the app store install "Windows Terminal" by Microsoft
  - this makes it easy to switch between CMD, Powershell, and WSL
- Rename the PC as `manager`
  - From administrative powershell
    - `Rename-Computer -NewName manager`
    - `Restart-Computer`
- Install WSL
  - **Start** > **Settings** > **Add an optional feature**
  - Click **More Windows features**
  - Check **Windows Subsystem for Linux**
  - Click **OK**
  - Click **Restart now**
  - Log back in and open privileged shelll
    - `wsl --list`
    - `wsl --list --online`
    - `wsl --install -d Ubuntu-22.04`
      - feel free to customize
      - Enter the username (i.e., `ansible`) and password to use
      - If you use a username other than `ansible`, please create the `ansible` user and use that for your Ansible work
- Configure Network interfaces
  - Settings > Network & Internet
  - Click Ethernet > First Interface (connected)
    - Network profile: Private
  - Click Ethernet > Second Interface (No Internet)
    - IP assigment: Click **Edit**
    - From dropdown select Manual
    - Slide to enable **IPv4**
      - We cannot set the IP address without a gateway IP or DNS from this interface!
  - Click **Start** > **Settings** > **Network & Interface** > **Ethernet**
    - Click **Change adapter options**
    - Open the adapter (i.e., **Ethernet 3**) with "Unidentified network"
    - Click **Properties**
    - Double-click **Internet Protocol Version 4** (TCP/IPv4)
    - Change to "Use the following IP address"
      - Use the following IP address:
        - IP address: **192.168.41.100**
        - Subnet mask: **255.255.255.0**
        - Gateway: Leave empty
        - Leave DNS entries empty
        - Click OK
      - Click OK
    - Click Close
- Install additional Windows applications
  - [Chrome browser](https://www.google.com/chrome/)
  - [WinSCP](https://winscp.net/eng/download.php)
- Install additional WSL packages
  - `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`
  - Install Ansible, modules and requirementes
    - `sudo apt install -y ansible python3-paramiko python3-pip`
    - `ansible-galaxy collection install community.general vyos.vyos check_point.mgmt`
    - `python3 -m pip install XenAPI`
- Generate ssh RSA key for user `ansible`
  - Open WSL terminal (Start > search WSL, or open Windows Terminal and click the dropdown carrot and click Ubuntu)
  - `ssh-keygen -o`
    - <ins>Do not</ins> enter a passphrase
    - Accept all defaults (press enter)
  - The public key you will be using:
    - `cat ~/.ssh/id_rsa.pub`
- Set up basic configuration files for Ansible
  - Create `ansible.cfg` from [ansible.cfg](ansible/ansible.cfg)
  - Create `inventory` from [ansible.cfg](ansible/inventory)
    - Note the values are commented out; we will confirm and enable these IPs later in the Lab
    - Under `[router]` put the Lab IP address of the router (yes, the simulated Internet IP; the path to the Lab isn't configured yet)

# Configure VyOS Router
- Log back in to console
- Configure eth0 interface
  - `configure`
  - `set interfaces ethernet eth0 address dhcp`
  - `set service ssh`
  - `commit`
  - `save`
  - `exit`
  - Get the IP address on eth0
    - `show interfaces ethernet eth0 brief`
- From "manager" VM Configure key login in VyOS
  - `ssh ansible@<vyos_lab_ip>`
    - accept the key
    - log in with password
  - Log in to VyOS as `ansible`
  - `configure`
  - `set sytem login user ansible authentiation public-keys home type 'ssh-rsa'`
  - `set sytem login user ansible authentiation public-keys home key '<valueofkey>'`
    - paste in contents of the id_rsa.pub file on manager <ins>without the leading `ssh-rsa`</ins>
  - `commit`
  - `save`
  - `exit`
- Test Ansible access
  - `exit`
  - the `inventory` files should have the VyOS "public" IP without the "#" comment character
  - everything else should be "commented out"
  - `ansible all -m ping`
  - You are expecting `SUCCESS` and `"ping": "pong"`
- Configure router using Ansible
  - Create router.yml from [router.yml](ansible/router.yml)
  - `ansible-playbook router.yml`
  - Testing
    - Login in to the VyOS router
      - `show interfaces`
    - Spin up a temporary VM based on template `win10-template` on the **build** network
      - it should be get DHCP information and be able to connect to the Internet

# Configure SMS
- Log in to console of SMS
  - Username `admin` and the password you selected
- Set IP address information
  - `set interface eth0 ipv4-address 192.168.41.20 mask-length 24`
  - `save config`
- Log in to `manager` and open a WSL shell
  - `ssh ansible@192.168.41.20`
    - you will be in the default home directory `/home/ansible`
- Create new authorized_keys file and add the key
  - `mkdir -v .ssh`
  - `chmod -v u=rwx,g=,o= ~/.ssh`
  - `touch ~/.ssh/authorized_keys`
  - `chmod -v u=rw,g=,o= ~/.ssh/authorized_keys`
  - Add the public key from `manager` to the files
    - `cat > .ssh/authorized_keys`
      - paste in the key
      - press Control-D

- Test Ansible access
  - `exit`
  - uppdate the inventory, uncomment to IP of the SMS 192.168.41.20
  - `ansible all -m ping`
  - You are expecting `SUCCESS` and `"ping": "pong"` for 192.168.41.20
- Configure SMS using Ansible
  - set hostname 
  - configure FTW using ansible

# Configure Branch 1

## Configure Branch 1 firewalls
- Initial settings
  - set IP information
  - set hostname
  - configure ansible SSH RSA keys
- FTW using Ansible
- Gaia config
- Create cluster
- policy
- DHCP helper in DMZ
- Move management workstation to Branch 1 LAN

## Configure DMZ Servers
Set up NAT and rules

IIS and Apache

## HTTPS Inspection
- HTTPS inspection

# Configure Branch 2
- Initial settings
- FTW
- Gaia config
- Create cluster
- policy
- VPN tunnel bring up
- DHCP helper?????

# Configure Branch 3
- Initial settings
- FTW
- Gaia config
- Create cluster
- policy
- VPN tunnel bring up
- DHCP helper?????

