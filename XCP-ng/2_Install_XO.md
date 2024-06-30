# Install XO Three ways
In a production environment you would use a paid Xen Orchestra (XO) virtual Appliance (VOA) to manage your XCP-ng environment. Your new host comes with a Quick Deploy method to use the XOA.

The XOA comes with a free trial, without which a large amount of functionality is disabled. Vates also provides a method to to build your own XO in a Linux server with all the features enabled except updates.

In this Lab you will get to experience both processes. We will start with the XOA to experience it, and then use it to easily build your own fully-featured manager beyond the initial trial period.

NOTES
- The XO server, whether the XOA virtual appliance or a separate server, will have its own IP address
- Another managment solution, XOLite is in beta

# Getting Started with Quick Deploy and XOA
## Option 1 - Quick Deploy
- Point your browser to the IP address of the NUC
  - Example: https://192.168.99.100
- Under management tools, click Quick Deploy under Xen Orchestra
- Login with the root password you set earlier
- Leave the network settings at their defaults to use DHCP (later set up a DHCP reservation)
- Click NEXT
- Create Admin account on your XOA
  - Username: `admin`
  - Password: `labboss`
- Register your XOA
  - xen-orchestra.com username: *use the value you used when registering*
  - xen-orchestra.com username: *use the value you used when registering*
- Set the XOA machine password
  - Login: `xoa` (default)
  - Password: `labboss`
- Click DEPLOY
- Wait as the XOA image is downloaded and the VM deployed
- Your browser is automatically redirected to the login page on the new IP address

## Option 2 - Vates Desploy Page
- Direct your browser to
  - https://vates.tech/deploy
 
## Log In and Apply Updates
- Point your browser to the IP address of the XOA
- Log in as username `admin` and password `labboss`
- Apply Updates
  - Click XOA from the left menu then click Updates
  - If an upgrade is available, click Upgrade and wait for the upgrade to complete and for XOA to reconnect
    - Click Refresh to connect as needed
    - In my testing I had to upgrade two times

# Build Your Own XO Server
The default XOA VM was created on Debian Jessie 8.0, 2 vCPUs, 2GB RAM, 20GB storage, 1 interface. We will build own using Ubuntu 22.04.

Overview
- Create new Ubuntu 20.04 using the Hub template
- Add more disk space
- Upgrade to Ubuntu 22.04
- Install XO

## Create New Ubuntu Server Using Hub
The "Hub" offers older options. We will install Ubuntu 20.04 and upgrade it to 22.04 for this lab.

- Log in to the XOA web page/portal
- Click Hub from menu on the left
- Under **Ubuntu 20.02** click **Install** to install the image
  - wait for the tasks to complete; monitoring process by clicking **Tasks** in the left menue
- Under **Ubuntu 20.02** click **Create**
    - Click OK to accept the pool (there is only one)
    - Name: XO-Ubuntu
    - Description: XO on Ubuntu
    - vCPU's: 2 (default, same as VOA)
    - RAM: 2GB (default, same as VOA)
    - You cannot change the disk size; we will increase is shortly
    - Select **Custom config**
      - In "User config" add the line:
        - `password: changeme`
    - Click Show advanced settings
      - Add check to Auto power on
      - Add check to Destroy cloud config drive after first boot :?:
  - Click Create
- Apply updates for 20.04
  - Open the VM's Console
  - Log in as `ubuntu`/`changeme`
  - You will be prompted to change your password
  - `sudo apt update && sudo apt upgrade -y`
    - if you are prompted about updating a configuration file, select Y (update to the maintainer's version)
- Remove vm-tools
  - `sudo apt remove open-vm-tools -y`
  - `sudo rm -r /etc/vmware-tools`
  - `sudo rm /etc/systemd/system/open-vm-tools.service`
  - `sudo rm /etc/systemd/system/vmtoolsd.service`
  - `sudo rm -r /etc/systemd/system/open-vm-tools.service.requires`
  - `sudo apt autoremove`
- Reboot
  - `sudo reboot`
- Increase storage to 20GB
  - shut down the VM
    - use the Web GUI to Stop it, or the console command `sudo poweroff`
  - On the VM's **Disks** tab click on the disk size `6 GiB` and enter `20` press enter
  - 6GB is not enough to do the distirbution upgrade, much less run XO
- Start the VM (click the Start icon in the Web GUI)
- Perform a release upgrade
  - Open the VM's Console
  - Log in as user `ubuntu` and the password you selected
  - `sudo do-release-upgrade`
  - Enter `y` to continue when prompted
  - Select `Yes` to allow service restarts
  - You will be prompted to keep existing settings (N) or use the maintainer's settings (Y); generally either choose Y to all or N to all; my initial test is Y to all
  - Approve removing obsolete packages
  - Approve rebooting the system
- Verify upgrade
  - ssh to the VM
  - `cat /etc/os-release`
  - confirm the version is now 222.04 LTS (Jammy Jellyfish)
- Change hostname
  - View current hostname: `hostnamectl`
  - Set the new hostname: `sudo hostnamectl set-hostname xo-ubuntu`
  - Optionally set the pretty name: `sudhostnamectl set-hostname "XO Ubuntu Server for managing XCP-ng" --pretty`
  - Confirm it has changed: `hostnamectl`
  - 

## Option 1 - Build on XCP-ng Using XOA and Replace XOA
## Option 2 - Build on Another Device (Even a VM on your Laptop running VirtualBox)
