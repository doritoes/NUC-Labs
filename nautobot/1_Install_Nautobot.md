# Install Nautobot
This corresponds to chapter 3 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

The passwords used in the Lab are weak and are only suitable for Lab use. Use secure authentication in production. In this Lab, I used Nautobot 2.3.12 with Django 4.2.16.

## Network Architecture
For this Lab you can install in your home lab network.

## Install Ubuntu Server
The first step is to install Ubuntu Server, upon which we will install Nautobot. This lab was primarily tested on VMware Workstation Pro.

See the tutorial https://ubuntu.com/tutorials/install-ubuntu-desktop#1-overview

### Option 1 - NUC
- Download the [latest ISO file](https://ubuntu.com/download/server)
  - For this Lab we are using Ubuntu Server 24.04 LTS
- Create a bootable USB stick from the ISO
  - 💡[balenaEtcher](https://etcher.balena.io/#download-etcher) is recommended to create a bootable USB stick from the ISO
  - If your workstation is Windows, the Portable version is perfect for the task
  - Click **Flash from file** and select the downloaded ISO file
  - Click **Select target** and select the the USB stick you inserted
  - Click **Flash!** and allow the command shell to continue
  - Wait for the flash and verification to complete
  - Safely eject the USB stick (yes, there are two "drives" on the USB stick)
- Boot the NUC from the bootable USB stick
  - Connect to keyboard, mouse and power
    - Optionally connect to wired network for faster setup
  - Insert the USB stick
  - Reboot or power on the NUC
  - Press F10 at the boot prompt
  - Select the USB stick (USB UEFI)
- Follow the prompts to install Ubuntu on the NUC

### Option 2 - VM
- Download the [latest ISO file](https://ubuntu.com/download/server)
  - For this Lab we are using Ubuntu Server 24.04 LTS, and the file name is similar to `ubuntu-24.04.1-live-server-amd64.iso`
- Create a new VM that is based on the ISO we downloaded
  - There are a lot of options: VMware Workstation, Oracle VirtualBox, proxmox, XCP-ng, etc.
    - For example, on VMware Workstation Pro:
      - File > New Virtual Machine
      - Typical
      - Browse to select the ISO file you downloaded (it will automatically detect the distribution and version)
      - Name: nautobot
      - Disk: 80GB or more (not aware of a minimum value)
      - Customize Hardware
        - Memory: 2GB or more (testing 4GB in Lab)
        - vCPU: 2 or more (testing 4 in the Lab)
        - Network Adapter: Bridged, connect at power on

### Initial Ubuntu Server Installation
- Allow the system to come up to the "Install" screen and click **Install Ubuntu**
- Accept the language settings and optionally update the installer
- Accept the keyboard settings then accept **Ubuntu Server**
- Accept or configure the network connection (DHCP is fine for this Lab, but in production you want a fixed IP address: either a static IP or use a DHCP reservation)
- No proxy, and continue after the mirror passes tests
- Accept the entire disk and default settings
- **Edit** the root partition to use all the available space
  - ubutntu-lv [...] mounted at /
  - Edit it
    - Change size to the maximum size (i.e., 77.996G)
    - Save
  - TIP A second option is to add a partition for /opt and assign the space to /opt
- Done and then Continue
- Enter system and user information *you can modify these as desired*
  - Your name: **nauto**
  - Server name: **nautobot**
  - Username: **nauto**
  - Password: **nautobot123**
  - Continue
- Skip Ubuntu Pro
- <ins>Check</ins> Install OpenSSH server
- Don't select any feature server snaps
- ⏲️ Wait patiently for the **Installation complete!** message
- Select **Reboot Now**
  - Remove the installation media (USB stick or ISO file) when prompted and press **Enter**
- TIP Set up a DHCP reservation for your Nautobot server so it always has the same IP address
  - Home router: https://www.youtube.com/watch?v=dCAsHdRBrag
  - pfSense: https://www.youtube.com/watch?v=NNKZm49keaA
  - OPNsense: https://forum.opnsense.org/index.php?topic=34017.0

## Set up System
### Update and Install Packages
- Log in as user `nauto`
- Update the system packages
  - `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`
  - `sudo apt install -y git python3 python3-pip python3-venv python3-dev redis-server postgresql`
- Test
  - Redis: (using default localhost and tcp/6379)
    - `redis-cli ping`
    - successful test returns `PONG`
  - postgresql:
    - `sudo -iu postgres psql`
    - To exit: `\q`

### Install Nautobot
#### Create nautobot system user
It is best practice to run Nautobot as a user other than root. This user, `nautobot`, will own files and permissions and services will be configured to run under this account.

Create user:
- `sudo useradd --system --shell /bin/bash --create-home --home-dir /opt/nautobot nautobot`
- `sudo usermod -aG sudo nautobot`
- `sudo passwd nautobot`

Test:
- `eval echo ~nautobot`
- `ls -l /opt/ | grep nautobot`
  - Should be `drwxr-x---` and `nautobot nautobot`

### Create database for Nautobot
🔑 From now on, use the account `nautobot`. Log out of `nauto` and back in as `nautobot`.

Set up the Nautobot database:
- Manually
  - `sudo -iu postgres psql`
  - `CREATE DATABASE nautobot;`
  - `CREATE USER nautobot WITH PASSWORD 'nautobot123';`
  - `\connect nautobot`
  - `GRANT CREATE ON SCHEMA public TO nautobot;`
  - `\q`
- Using a script
  - `sudo -iu postgres bash`
  - Download [setup.sql](setup.sql) and create in `~/postgres`
  - `psql -f setup.sql`
  - `exit`
- Test the user
  - `psql --username nautobot --password --host localhost nautobot`
  - `\q`

#### Set up Python virtual environment
A Python virtual environment (virtual env or nenv) is strongly recommended. If you haven't used one yet, you're not alone. But it's not as difficult as you would imagine. This helps created isolated environments tailored to indivdual projects, preventing any interference with system packages or other projects.

 Here we create demonstrate configuring for the user `nautobot` right from the user `nauto`.
 
- Create venv
  - `sudo -u nautobot python3 -m venv /opt/nautobot`
- Configure the environment variables in the user `.bashrc` file
  - `echo "export NAUTOBOOT_ROOT=/opt/nautobot" | tee -a ~nautobot/.bashrc`
  - `echo "export NAUTOBOT_ALLOWED_HOSTS=*" | tee -a ~nautobot/.bashrc`
  - `echo "export NAUTOBOT_DB_USER=nautobot" | tee -a ~nautobot/.bashrc`
  - `echo "export NAUTOBOT_DB_PASSWORD=nautobot123" | tee -a ~nautobot/.bashrc`
- Test
  - Log out and back in as `nautobot`
  - `echo $NAUTOBOT_ROOT`

### Installing Nautobot
🔑 Nautobot should be installed as the `nautobot` user --do <ins>NOT</ins> install as `root`!
- Log in as user `nautobot`
  - Or, switch to the user: `sudo -ui nautobot`
- Install `wheel` so Python will use wheel packages when they are available
  - `pip3 install --upgrade pip wheel`
- Install Nautobot
  - `pip3 install nautobot`
    - ⏲️ Allow a couple minutes for it to install. Using wheel means pre-combiled binaries and faster installation.
  - NOTE You can specific the book version like so: `pip3 install nautobot==2.1.4`
  - NOTE You can install addition features (MySQL, LDAP, NAPALM, remote_storage, SSO, etc.) by modifying the pip3 install command
    - `pip3 install nautobot[all]` - in Lab testing, this failed
    - `pip3 install nautobot[napalm,mysqlclient]`
- Test
  - `nautobot-server --version`

### Configure Nautobot
- Initialize Nautobox basic configuration will create the `nautobot_config.py` tool.
  - `nautobot-server init`
    - 🗒️ for this Lab, I don't send installation metrics to the developers
- Test
  - `cat /opt/nautobot/nautobot_config.py`
- Customize `nautobot_config.py`
  - 🌱 maybe create a file for this
  - `vi $NAUTOBOT_ROOT/nautobot_config.py`
  - Required Settings
    - Uncomment (remote the leading" "#") the following parts
      - ALLOWED_HOSTS
      - CACHES
      - CONTENT_TYPE_CACHE_TIMEOUT
      - CERLERY_BROKER_URL
      - DATABASES
    - Example of what it could look like: [nautobot_config.py](nautobot_config.py)
- Database Migrations
  - `nautobot-server migrate`
    - ⏲️ This will take a while, be patient
    - NOTE This is not just for the initial setup; every time a new release is deployed, a new migrate is needed to update the database data models
- Create a Nautobot superuser to log in to the Nautobot web application
  - `nautobot-server createsuperuser`
    - Username: **admin**
    - Email address: *be creative*
    - Password: **nautobot123**
- Collect Nautobot static files (collect data not covered by the `migrate` command, also run for every release)
  - `nautobot-server collectstatic`
- Nautobot Check
  - Validate the configuration and check for common problems
  - `nautobot-server check`
  - NOTE It won't tell you if you forgot to run `nautobot-server collectstatic`
- Test run a development instance
  - `nautobot-server runserver 0.0.0.0:8080 --insecure`
  - Point web broswer to the IP address of VM using port 8080
    - Ex. http://192.168.99.17:8080
    - Log in as `admin`/`nautobot123`
    - Press control-C at the terminal to stop it
- Test Nautobot worker
  - Worker picks up the background tasks triggered by the Nautobot platform and executes them asynchronously. It Python Celery, a distributed task queue framework.
  - Log back in as `nautobot` at command line
  - `nautobot-server celery worker`
  - Press control-C to stop it
- Configure WSGI
  - Django applications run WSGI aplications behind HTTP server. Nanobot has uWSGI by default. For production builds, consider a more fully featured option.
  - In this test will will not use advanced features such as using a reverse proxy; therefore we will use `http` mode instead of `socket` and port 8001
  - Download [uwsgi.ini](uwsgi.ini) and copy to a new file `$NAUTOBOT_ROOT/uwsgi.ini`
  - Start it
    - `/opt/nautobot/bin/nautobot-server start --ini /opt/nautobot/uwsgi.ini`
  - Test
    - Point web browser to the IP address of the VM using port 8001
      - Ex. http://192.168.99.17:8001
    - Log in as `admin`/`nautobot123`
  - Press control-C at the terminal to stop it
- Check services
  - `systemctl status redis-server postgresql`
- Configure Nautobot as Linux service
  - Download [nautobot.service](nautobot.service) and copy to a new file `/etc/systemd/system/nautobot.service`
    - IMPORTANT This method uses credentials stored in plain text, NOT suitable for production!
  - Enable and start the new service
    - `sudo systemctl daemon-reload`
    - `sudo systemctl enable --now nautobot
  - Test
    - `sudo systemctl status nautobot.service`
    - Point your broswer to the VM's IP address on port 8001
      - Example: https://192.169.99.33:8001
      - 🌱 at this point i get a failure connecting to PostgreSQL
        - `sudo systemctl status postgresql`
        - If postgresql is `active (exited)`, it can still be up and runing. Confirm using `sudo -iu postgres psql`
        - Not sure how to fix this. Checked .bashrc of for user `nautobot`
  - Configure Nautobot workers as Linux service
    - IMPORTANT This method uses credentials stored in plain text, NOT suitable for production!
  - Download [nautobot-worker.service](nautobot-worker.service) and copy to a new file `/etc/systemd/system/nautobot-worker.service`
    - IMPORTANT This method uses credentials stored in plain text, NOT suitable for production!
  - Enable and start the new service
    - `sudo systemctl daemon-reload`
    - `sudo systemctl enable --now nautobot-worker
  - Test
    - `sudo systemctl status nautobot-worker.service`
  - Configure Nautobot Scheduler as Linux service
    - Download [nautobot-scheduler.service](nautobot=scheduler.service) and copy to a new file `/etc/systemd/system/nautobot-scheduler.service`
    - IMPORTANT This method uses credentials stored in plain text, NOT suitable for production!
  - Enable and start the new service
    - `sudo systemctl daemon-reload`
    - `sudo systemctl enable --now nautobot
  - Test
    - `sudo systemctl status nautobot-scheduler`
- Test all the services
  - `sudo systemctl status redis-server postgresql nautobot nautobot-worker nautobot-scheduler`
    - Read carefully to check for errors
## First-Time Configuration
