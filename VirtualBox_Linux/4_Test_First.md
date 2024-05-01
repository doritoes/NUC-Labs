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
