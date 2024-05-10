# Tear Down the Lab
Run the playbook:
  - `ansible-playbook destroy_fleet.yml`

Confirm all the VM's are cleaned up on the host
- are there any .vdi files in your home directory?
- is the 'VirtualBox VMs' subdirectory empty?
- was the `ubuntu-autoinstall` subdirectory removed?
