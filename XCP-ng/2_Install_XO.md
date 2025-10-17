# Install XO Two Ways
In a production environment you would use a paid Xen Orchestra (XO) virtual Appliance (VOA) to manage your XCP-ng environment. Your new host comes with a Quick Deploy method to use the XOA.

The XOA comes with a free trial, without which a large amount of functionality is disabled. Vates also provides a method to to build your own XO in a Linux server with all the features enabled except updates.

In this Lab you will get to experience both processes. We will start with the XOA to experience it, and then use it to easily build your own fully-featured manager beyond the initial trial period.

NOTES
- The XO server, whether the XOA virtual appliance or a separate server, will have its own IP address
- The other management solution, XO-Lite, is out of beta and GA in 8.3

# Getting Started with Quick Deploy and XOA
- Point your browser to the IP address of the NUC
  - Example: https://192.168.1.100
- Login to "XO-Lite" (Xen Orchestra Lite) with the root password you set earlier
- Under management tools, click Quick Deploy under Xen Orchestra
- Login with the root password you set earlier
- This is the basic access you get without deploying Xen Orchestrator
- Direct your browser to
  - https://vates.tech/deploy
  - This deploys Xen Orchestra 5 (Xen Orchestrator Appliance = XOA)
- Click **Got it, let's go!**
- Enter primary host information
  - Primary host: *IP address of the host, xcp-ng-lab1*
  - Login: **root**
  - Password: *enter the password you set earlier*
  - Click **Continue**
- Configure storage and network
  - Default storage and DHCP for the lab
  - Click **Continue**
- Create accounts
  - XOA ADMIN ACCOUNT
    - Login: `admin`
    - Password: `labboss`
  - XOA SSH ACCOUNT
    - Login: `xoa` (default)
    - Password: `labboss`
 - Click **Deploy**
 - Wait *patiently* as the XOA deployment completes (10-15 minutes)
   - downloads XOA image
   - VM deployed
   - TIP log in to the host's web portal again, and scroll to the bottom to watch the progress of these tasks (it give you and estimated completing time which is helpful)
  - When *XOA deployment successful!* is displayed
  - Click **Access XOA** to be redirected to the IP address of the XOA
  - TIP take this opportunity so set up a fixed IP address for the XOA for ease of use, then restart the XOA server

## Log In, Register, and Apply Updates to XOA
- Log in using the XOA ADMIN ACCOUNT you configured earlier
- You will need to register the XOA, you will be "reminded" constantly to do this
  - From the XOA menu, XOA > Updates
  - Registeration:
    - enter the username and password you registered with, then click **Register**
    - Optionally, you can click **Start trial** (30 days)
- Apply Updates
  - From the left menu Click XOA > Updates
  - If an upgrade is available, click **Upgrade** and wait for the upgrade to complete
    - If it remains Disconnected for too long, try clicking Refresh to re-connect

IMPORTANT XOA does not allow you to apply patches to the pool devices (the host) unless you start the trial or pay. Therefore we are going to build our own XO Server which will allow to apply patches to hosts.

# Build Your Own XO Server on XCP-ng
The default XOA VM was created on Debian 12, 2 vCPUs, 2GB RAM, 20GB storage, 1 interface. We will build our own XO server using Ubuntu 24.04 right on this host.

NOTE You can also build set up your XO server elsewhere, such as a VM on your Lab laptop

Overview
- Create new Ubuntu 24.04 using the Hub template
- Add more disk space
- Install XO
- Remove XOA

## Create New Ubuntu Server Using Hub
We will use the Hub's images to install Ubuntu 24.04.

Steps:
- Log in to the XOA web page/portal
- Click **Hub** from menu on the left
- Under **Ubuntu 24.04** click **Install** to install the image
  - accept defaults for pool and storage, and click **OK**
  - wait for the tasks to complete
    - monitor the process by clicking **Tasks** in the left menu
    - note the Pool tasks and the XO tasks being performed
    - NOTE in testing this took a long time
- Still in Hub, under **Ubuntu 24.04** click **Create** which is now enabled
  - Click **OK** to accept the pool **xcp-ng-lab1** (there is only one)
  - Name: **XO-Ubuntu**
  - Description: **XO on Ubuntu**
  - vCPU's: 2 (default, same as VOA)
  - RAM: 2GB (default, same as VOA)
  - You cannot change the disk size; we will increase it shortly
  - Under Install settings select **Custom config**
    - In "User config" section:
      - add the line: `password: changeme`
      - you can optionally set the hostname here; be aware the "{index}" is index value, starting with "0"; if you uncomment the hostname line the hostname will be set to the "name" of the VM in XO with a zero after it (e.g., XO-Ubuntu0)
  - Click **Show advanced settings**
    - Add check to **Auto power on** (this is important)
  - Click **Create**
- Increase storage to 20GB
  - The VM needs to be powered off (e.g., `sudo poweroff`)
  - On the VM's **Disks** tab click on the disk size `3.5 GiB` and enter `20` press enter
  - 3.5GB is not enough to run XO, and in testing we had issues just updating packages!
- Apply updates for 24.04
  - Open the VM's Console (click the Console tab)
  - Log in as `ubuntu`/`changeme`
  - You will be prompted to change your password
  - `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`
- Remove vm-tools
  - `sudo apt remove -y open-vm-tools`
  - `sudo rm -r /etc/vmware-tools`
  - `sudo rm /etc/systemd/system/open-vm-tools.service`
  - `sudo rm /etc/systemd/system/vmtoolsd.service`
  - `sudo rm -r /etc/systemd/system/open-vm-tools.service.requires`
  - `sudo apt autoremove -y`
- Change hostname
  - View current hostname: `hostnamectl`
  - Set the new hostname: `sudo hostnamectl set-hostname xo-ubuntu`
  - Optionally set the pretty name: `sudhostnamectl set-hostname "XO Ubuntu Server for managing XCP-ng" --pretty`
  - Confirm it has changed: `hostnamectl`
- Reboot
  - `reboot`
- Rename the VM from XCP-ng to `xo-ubuntu`
- Install guest tools
  - Connect the guest-tools.iso ("Select disk(s)...", select it from the dropdown)
    - if you have having trouble with a half-connected cdrom/dvd, power off the VM, eject the iso, and try again
  - Open Console
  - Mount the tools ISO
    - `sudo mount /dev/xvdb /media`
      - in older versions it was "sudo mount /dev/cdrom /media"
    - STUCK here, not getting the guest tools CD mounted
    - `cd /media/Linux`
  - Install the tools
    - `sudo ./install.sh`
    - you may be prompted to enter your password
    - you are prompted accept the change
    - you are reminded to reboot
  - Unmount the ISO
    - `cd ~`
    - `sudo umount /media`
  - `sudo reboot`
  - Eject guest-tools.iso
  - Back in XO, the General tab will show the management tools are detected

## Install Xen Orchestra (XO) on the Ubuntu Server
Reference: https://www.youtube.com/watch?v=fuS7tSOxcSo

1. `git clone https://github.com/ronivay/XenOrchestraInstallerUpdater.git`
2. `cd XenOrchestraInstallerUpdater`
3. `cp sample.xo-install.cfg xo-install.cfg`
4. `vim xo-install.cfg`
    - change PORT to "443"
    - uncomment `PATH_TO_HTTPS_CERT` line
    - uncomment `PATH_TO_HTTPS_KEY` line
5. `sudo apt update && sudo apt install -y openssl`
6. `sudo mkdir /opt/xo`
7. `sudo openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /opt/xo/xo.crt -keyout /opt/xo/xo.key`
    - Country: US
    - State: New York
    - Locality: New York
    - Organization Name: Lab
    - Organizational Unit Name: Virtual
    - Common Name: xo
    - Email address: x@x.x
9. `sudo ./xo-install.sh`
    - If you have less than 3GB of memory you need to accept the warning:
      - WARNING: you have less than 3GB of RAM in your system. Installation might run out of memory.
      - In my testing this did not break the installation; it's possible to increase the VM's RAM if desired
    - Choose option 1 to kick off install
    - Wait for it to complete (updates are much faster; the first installation takes time)
10. Get the IP address of the VM: `ip a` or `hostname -i`

NOTE To update the XO server, run the same xo-install.sh script and select "2. Update".

## Configure the XO on Ubuntu
1. Point browser to the IP
    - Example: https://192.168.1.103
    - Accept the warnings for the self-signed certificate
2. Log in
    - user: admin@admin.net
    - pass: admin
3. Add new user to replace admin@admin.net
    - Settings > Users > Create
      - Name: admin
      - Permissions: Admin
      - Select a password
    - Click Sign out then sign in as the new user `admin`
    - Remove user admin@admin.net
4. Add the XCP-ng host ("server")
    - Settings > Servers
    - Enter information for the host
      - Label: xcp-ng-lab1
      - Address:port: the IP address of the host
      - Username: root
      - Password: the root password you configured
      - "Unauthorized certificates" Slider: enable it
      - Click Connect
5. Make sure the XO Ubuntu VM is configured to stay up and prevent accidental deletion
    - Home > VMs
    - Click XO-Ubuntu
    - Click Advanced tab
      - Auto power on: YES
      - Protect from accidental deletion: YES
      - Protect from accidental shutdown: YES

## Remove the XOA
You may choose to keep the XOA virtual appliance if you have enough CPU cores and RAM for the extra overhead. For this Lab I am removing it:
1. Login again to XO
2. Home > VMs
3. Check the box for XOA
4. Click More > Remove
5. Click OK to confirm

## Reboot the Host
1. ssh to the IP address of the host xcp-ng-lab1 as user root with the root password you select
2. Option 1 - `reboot`
3. Option 2 -  `xsconsole`
    - Reboot or Shutdown
    - Reboot Server

IMPORTANT Note how long it can take for the host and then the guest to come up. Don't panic too early.

## Log Back In and Confirm
1. Point browser to the XO IP
    - Example: https://192.168.1.103
2. Log in with the user you created
3. If you are able to log in, your XO server is working!

## Install Pool Patches
This is how the host system (XCP-ng) is updated. The XOA free version does not allow you to apply patches to the host! This is one of the main reasons to run our own XO on Ubuntu.
1. Log in to XO again
2. Home > Pools
3. Click on the host xcp-ng-lab1
4. Click the Patches tab
5. Click Install pool patches
    - note the message "This will automatically restart the toolstack on every host. Running VMs will not be affected. Are you sure you want to continue and install all the patches on this pool?"
    - Click OK
