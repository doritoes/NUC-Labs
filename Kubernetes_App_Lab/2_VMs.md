# Deploy VMs
Deploy virtual machines (VMs) running Linux inside Oracle VirtualBox. We will use a custom "user-data" file with an unattended installation of Ubuntu.

We will create this template file for use in our Ansible playbook to Generate Custom Unattended Ubuntu Install ISO. This will allow us to customize each VM to our requirements.

## Create file variables.yml
Create a new variables.yml file in the home directory (you are the user ansible now, so it's in /home/ansible).

Example file: `variables.yml` ([variables.yml](variables.yml))

Modify the new `variables.yml` file as follows:
- Replace the **ssh_key** with the one you saved earlier
- Replace the **bridge_interface_name** value with the interface of your host machine
  - Ex., run `ip a` and you will find the list of interfaces and IP addresses

## Create file servers.yml
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
  - on your Host computer run route -n from Terminal/command line to see the gateway IP
- IPv4DNS: a DNS server
  - on your host computer run `nmcli device show`
  - shows the IP4.DNS[1] address and the IP4.GATEWAY address
  - you can always configure the Google DNS IP 8.8.8.8 here

The Search domain should match the domain you configured on your router, if any. Or use lablocal for a safe value.

You will also specify VM resources for each server:
- DiskSize in MB (10240 = 102240 MB = 10GB)
- MemorySize in MB (1024 = 1GB)
- CPUs in number of virtual cores

You will also enter the Name (VM name), Hostname (VM's OS hostname), local sudoer username and password.

In the following example the Lab router (192.168.99.254) provides a DNS resolver to clients.

Lab server list
- 1x Controller
  - 2 CPU cores
  - 2 GB RAM
  - 60 GB storage
- 1x SQL server node
  - 2 CPU cores
  - 2 GB RAM
  - 250 GB storage
- 2x app nodes
  - 1 CPU core
  - 2 GB RAM
  - 60 GB storage

This consumes 6 of the 8 cores in the NUC host, 8GB of RAM and <500GB storage.

If you have more cores, give 2 cores to each App node and add another App node for 3 total (10 cores + 2 overhead = 12 cores at least).

Use `servers.yml` ([servers.yml](servers.yml)) as a the example for your `server.yml` file.

## Create jinja template file fleet-user-data.j2
🚧 Continue here ...

Use `fleet-user-data.yml` ([fleet-user-data.yml](fleet-user-data.yml)) as a the example for your `fleet-user-data.yml` file.

## Create the Playbook to Deploy the VMs in VirtualBox while Managed by Ansible
Use `fleet-user-data.yml` ([build_fleet.yml](build_fleet.yml)) as a the example for your `build_fleet` file.

## Run the Playbook and Test the VMs
The next playbook is the one that will do all the work.

Overview:
- set up working directory
- download the Ubuntu 20.20 server ISO (this may take some time depending on the Internet connection)
- create a customer bootable ISO for each server
- create a VM for each server with the required resources
- power on the new VMs in headless more
- add the static IP addresses assigned to the VMs to the inventory file inventory
- wait for the servers to boot and be configured, and finally come online
- add the ssh keys to the known_hosts file to enable seamless control using Ansible

`ansible-playboook build_fleet.yml`

Do a quick ansible ping:

ansible -i inventory all -m ping

## Configure Servers
Now that the servers are built and online, we will configure the local user listed in servers.yml and update all packages. A common issue with Ubuntu 20.04 regarding DNS failed lookups will be fixed.

Overview
- Extend the disk partition(s) to use all of the available disk space
- Enable username & password login and add the local user specified in the servers.yml file
- Update and upgrade all packages (rebooting as needed)
- Disable the DNS stub listener to prevent later issues with failed DNS lookups

configure_fleet.yml

`ansible-playboook configure_fleet.yml`

## Test Servers
Do a quick ansible ping:

ansible -i inventory all -m ping
You can ssh to the servers and confirm everything is working correctly with the correct amount of resources.

# Destroy Servers and Redeploy
Let's create a playbook to remove all the servers clean up the environment. We will using ansible re-deploy with fresh images.


Now remove all the servers and rebuild them:

ansible-playbook destroy_fleet.yml
ansible-playbook build_fleet.yml
ansible-playbook -i inventory configure_fleet.yml
ansible -i inventory all -m ping
