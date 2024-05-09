# Test First Ubuntu Server VM
In this step we will test the basic connectivity to our new server and practice performing maintenance tasks using Ansible.

## Test SSH Access
- Log in to your host machine and become the user `ansible`
  - Option 1: Log in to the host machine as user `ansible`
  - Option 2: Log in as usual to the host maching and `su - ansible`
- SSH to the VM
  - `ssh ansible@<ip_address>`
  - The IP address is displayed on the VM's console screen when it starts up
  - *See [Appendix - Discover IP](Appendix_Discover_IP.md) for more ways to find the IP address*
- The login succeeds without entering a password
  - you do need accept the fingerprint to add to the list of known hosts
  - user `ansible` will be used to manage the server

## Test Ansible to the New Server
### Create the Inventory File
- Return to the host machine and user `ansible`
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
  - this runs the reboot command on the VM

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
Congratulations on your first VM deployed using Ansible on Virtualbox! Let's look at using Ansible to remove this first VM.

### Simple Playbook
- Log back into your Host system as user `ansible`
- Create playbook `destroy_vm_1.yml` ([destroy_vm_1.yml](destroy_vm_1.yml))
- Run the playbook
  - `ansible-playbook -i hosts destroy_vm_1.yml`
- Note how it fails

### Playbook Attempt 2
- Create playbook `destroy_vm_2.yml` ([destroy_vm_2.yml](destroy_vm_2.yml))
- Run the playbook (the VM should be running)
  - `ansible-playbook -i hosts destroy_vm_2.yml`
- Note how it fails
  - VM stops, but not removed
  - if you run it a second time, it fails on shut down task

💡 What ideas do you have to make the script work? Perhaps shutting down the VM if necessary before removing it? There are many ways.

- Bring the VM back up
  -  `vboxmanage startvm my_vm`
  -  if you are using a remote SSH session you can't start a gui session; instead use
    -  `vboxmanage startvm my_vm –type headless`
- Instead of the graceful poweroff method above, you can also experiment with
  - `vboxmanage controlvm my_vm poweroff`
  - Does this take less time than a graceful shutdown?
- Research another option
  - `vboxmanage controlvm my_vm poweroff –type emergencystop`
  - Why would you only use this option if you didn't care of the VM was corrupted?

### Better Playbooks
This is a quick and dirty solution, no better than running the commands manually. It does wait a minute "in case it's on".
- Create playbook `destroy_vm_3.yml` ([destroy_vm_3.yml](destroy_vm_3.yml))
- Run the playbook (the VM should be running)
  - `ansible-playbook -i hosts destroy_vm_3.yml`

Using `ignore_errors` can be useful. Test this out and see how removes the VM whether it is “on” or “off”.
- Recreate the VM as needed: `ansible-playbook -i hosts create_vm.yml`
- Create playbook `destroy_vm_4.yml` ([destroy_vm_4.yml](destroy_vm_4.yml))
- Run the playbook (VM locked, try with the VM running and again when stopped)
  - `ansible-playbook -i hosts destroy_vm_4.yml`

The following is a rather vicious one-liner to remove the VM, running or not. The use of &&' (and) and || (or) to handle the error states. The VM is gone whether it was up or down.
~~~~
vboxmanage controlvm my_vm poweroff --type emergencystop && vboxmanage unregistervm --delete my_vm || vboxmanage unregistervm --delete my_vm
~~~~
However you cannot just put this one-liner into a playbook. Only the first command completes, or if it fails it just exists.
- Recreate the VM as needed: `ansible-playbook -i hosts create_vm.yml`
  - NOTE the new VM may get a new IP address, so update `hosts` file as needed
- Create playbook `destroy_vm_5.yml` ([destroy_vm_5.yml](destroy_vm_5.yml))
- Run the playbook (try with the VM running and again when stopped)
  - `ansible-playbook -i hosts destroy_vm_5.yml`
- `vboxmanage list vms`

Using the pipe (|) to run multiple commands doesn't solve the issue. If the VM is off, it is deleted successfully. But if it's on, the VM is powered off but not removed.
- Create playbook `destroy_vm_6.yml` ([destroy_vm_6.yml](destroy_vm_6.yml))
- Run the playbook (try with the VM running and again when stopped)
  - `ansible-playbook -i hosts destroy_vm_6.yml`

## Why So Complicated?
Oracle Virtualbox doesn't have the nice modules for Ansible that VMware vCenter has. The GUI interface is the easiest way to manage virtual machines, but we can do the changes by command line.

Ansible can do the logic we want, but it's not straightforward:
1. Is the VM powered on? How can we check that with Ansible?
    - If yes, power if off
2. Is the VM off now?
3. Delete the VM
4. And yes, error handling

`wait_for` is a useful command. You wait for an ssh probe on stop working on the server. Or we could store the VM servers we create in a local table by VM, hostname name and IP. Our scripts could use that data.

## Learn More
### Rebooting by Group
Here is an example of a playbook to reboot the servers in the group [servers].
- `reboot_servers.yml` ([reboot_servers.yml](reboot_servers.yml))
- `ansible -i hosts reboot-servers.yml`

What do you think this playbook will do?
- Open the VM's console and watch what happens when you run `ansible-playbook -i hosts reboot_servers.yml`
- When does the reboot task complete?

### When Done
When you are done experimenting, clean up the VM.
- `ansible-playbeook -i hosts destroy_vm_4.yml`
- `vboxmanage list vms` should no longer show any VMs
