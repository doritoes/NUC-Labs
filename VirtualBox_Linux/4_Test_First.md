# Test First Ubuntu Server VM
In this step we will test the basic connectivity to our new server and practice performing maintenance tasks using Ansible.

## Test SSH Access
- Log in to your host machine and become the user `ansible`
  - Option 1 - ssh to your host machine as the user `ansible`
  - Option 2 - log in as usual and run `su - ansible`
- SSH to the IP address of the new server
  - `ssh <ip_address>`
  - The IP address is displayed on the VM's console screen when it starts up
  - *See [Appendix - Discover IP](Appendix_Discover_IP.md) for more ways to find the IP address*
- The login succeeds without entering a password
  - you do need accept the fingerprint to add to the list of known hosts
  - user `ansible` will be used to manage the server

## Test Ansible to the New Server
### Create the Inventory File
- Become user ansible (i.e., su - ansible)
- Create a simple inventory file named `hosts` in the ansible user's home directory (/home/ansible/)
- Put the VM's IP address in the file `hosts`, following the template below
~~~~
[servers]
<ip_address_of_VM>
~~~~
- Confirm the inventory by listing it to the screen
  - `ansible -i hosts all --list-hosts`

### Confirm the Server is Up
Still as user `ansible`, run some ad hoc Ansbile commands to test
- `ansible -i hosts all -m ping`
- `ansible -i hosts servers -m ping`
- `ansible -i hosts servers -a "sudo /sbin/reboot"`

### Update Ubuntu
Next we will use a playbook to update the software packages on the new server.
- Create playbook `update_servers.yml` from this repo ([update_servers.yml](update_servers.yml))
- Run the playbook
  - `ansible-playbook -i hosts update_servers.yml`
 
### Disable DNS Stub Resolver
Even though each node receives its DNS information via DHCP, Ubuntu 22.04 will at times fail to resolve names. Rebooting solves the problem temporarily, but it will come back. The following playbook will disable the DNS Stub listener to prevent the problem.

- Create playbook `disable_dns_stub.yml` from this repo ([disable_dns_stub.yml](disable_dns_stub.yml))
- Run the playbook
  - `ansible-playbook -i hosts disable_dns_stub.yml`

## Delete our First VM
Congratulations on your first VM deployed using Ansible on Virtualbox!

## Learn More
## Rebooting by Group
Here is an example of a playbook to reboot the servers in the group [servers].
- `reboot_servers.yml` ([reboot_servers.yml](reboot_servers.yml))

What do you think this playbook will do?
- Open the VM's console and watch what happens when you run `ansible-playbook -i hosts reboot_servers.yml`
- When does the reboot task complete?
