# Deploy Fleet of VMs
In this step we will use playbooks to deploy and manage servers from an inventory of servers.

Overview
- Set up the variables.yml file
- Set up up the server.yml file with the information about the servers we want
- Create jinja templates
- Create playbook to deploy servers
- Create playbook to update packages on the servers

## New variables_fleet.yml File
- Create a new `variables.yml` file in the home directory (you are the user `ansible` now, so it's in /home/ansible)
  - Example file: `variables_fleet.yml` ([variables_fleet.yml](variables_fleet.yml))
  - Modify  the new `variables_fleet.yml` file as follows:
    - Replace the **ssh_key** value with the one you saved earlier
    - Replace the **bridge_interface_name** value with the interface of your host machine
      - Ex., run ip a and you will find the list of interfaces and IP addresses

## Create servers.yml File
For this level of automation, we need to know the IP addresses of the servers. Therefore instead of relying on DHCP, we will build the servers with static IP addresses.

These static IP addresses:
- are on the same subnet as your host machine
- need to be unique (no conflicts); assign IP addresses that are not in your router's DHCP scope/range
  - This is Linux, so static IP addresses are NOT in the DHCP scope; Windows fixed IP addresses are in the scope range
- are expressed in CIDR notation for the sake of the autoinstaller
  - Ex. 192.168.1.25 with the subnet 255.255.255.0 = 192.168.1.25
  - Ref. https://www.freecodecamp.org/news/subnet-cheat-sheet-24-subnet-mask-30-26-27-29-and-other-ip-address-cidr-network-references/

Since we are doing static IP addresses you will also need to provide:
- IPv4Gateway: the IP address of your router
  - on your host computer run route -n from Terminal/command line to set the gateway IP
- IPv4DNS: a DNS server
  - on your host computer run `nmcli device show`
  - shows the IP4.DNS[1] address and the IP4.GATEWAY address
  - you can always configure the Google DNS IP 8.8.8.8 here

The Search domain should match the domain you configured on your router, if any. Or use `lablocal` for a safe value.

You will also specify VM resources for each server:
- DiskSize in MB (10240 = 102240 MB = 10GB)
- MemorySize in MB (1024 = 1GB)
- CPUs in number of virtual cores

You will also enter the Name (VM name), Hostname (VM's OS hostname), local sudoer username and password

In the following example the Lab router (192.168.99.254) provides a DNS resolver to clients.
- Create a new variables.yml file in the home directory (you are the user `ansible` now, so it's in /home/ansible)
  - Example file: `servers.yml` ([servers.yml](servers.yml))
- Modify the names, IP addresses, gateways, DNS server, and searchdomain information to match your Lab network
- Use the default memory, storage, and vCPI infomration or modify to your requirements

## Create fleet-user-data.j2 Jinja File
Next create the jinja (j2) template used to create the user-data file for each server's automatic installer ISO image.
- Create a new `fleet-user-data.j2` ([fleet-user-data.j2](fleet-user-data.j2))

## Deploy Servers
Overview:
- set up working directory
- download the Ubuntu 20.20 server ISO (this may take some time depending on the Internet connection)
- create a customer bootable ISO for each server
- create a VM for each server with the required resources
- power on the new VMs in headless mode
- add the static IP addresses assigned to the VMs to the inventory file inventory
- wait for the servers to boot and be configured, and finally come online
- add the ssh keys to the known_hosts file to enable seamless control using Ansible

Steps:
- Create a new file `build_fleet.yml` ([build_fleet.yml](build_fleet.yml))
- Run the playbook
  - `ansible-playbook build_fleet.yml`
 
## Configure Servers
Now that the servers are built and online, we will configure the local user and update all packages.

Overview:
- Extend the disk partition(s) to use all of the available disk space
- Enable username & password login and add the local user specified in the servers.yml file
- Update and upgrade all packages (rebooting as needed)
- Disable the DNS stub listener to prevent later issues with failed DNS lookups

- Steps:
- Create a new file `configure_servers.yml` ([configure_servers.yml](configure_servers.yml))
- Run the playbook
  - `ansible-playbook configure_servers.yml`
## Test Servers
- Do a quick ansible ping
  - `ansible all -m ping`
- Log in to servers and confirm everything is working with the correct user account & password, CPUs, storage, RAM
  - ssh to the IP address of the server (password-less login as ansible using key)
  - ssh to the IP address of the server as the user you specified in servers.yml
    - Ex. ssh myuser@192.168.99.201
    - You should be prompted for the password
  - Test sudo access for each user
  - Check the amount of disk space: df -h
  - Check the amount of RAM: free -h
  - Check the number of CPUs: grep processor /proc/cpuinfo | wc -l

💡 Can you write a playbook to display this information? Can you use the moddule "setup" to do the same?

## Destroy
Destroy all the VMs using the playbook below. Notice that it removes the working directory and even cleans up the known_hosts and inventory file.

Steps:
- Create a new file `destroy_fleet.yml` ([destroy_fleet.yml](destroy_fleet.yml))
- Run the playbook
  - `ansible-playbook destroy_fleet.yml`
- Be amazed at how quickly everything cleaned up and destroyed!

## Rebuild
- Optionally, update the `servers.yml` file to add an additional server or two. Watch out that you don't run out of RAM, CPU cores, or disk.
- Rebuild the servers
  - `ansible-playbook build_fleet.yml`
  - `ansible-playbook configure_servers.yml`
 
## Learn More
### CSV Files
Explore using CSV files from Excel. Let's face it, many times we use Excel to collect the data and don't want to bother converting it to YML (or JSON for that matter).

Save the spreadsheet as a CSV (comma separated value) file so ansible can read it.

*See https://docs.ansible.com/ansible/latest/collections/community/general/read_csv_module.html*

IMPORTANT If the CSV file is created directly from Excel; you many need to look at the “dialect” option. Yes, this makes a difference to the underlying Python methods.
