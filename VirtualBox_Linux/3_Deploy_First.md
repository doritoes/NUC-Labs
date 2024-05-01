# Deploy First VM
In this step you will create a playbook to deploy an Ubuntu server using Virtualbox.

## Create Playbook
- Run the Playbook
  - `ansible-playbook create_vm.yml`
 
## Learn More
### Experiement with Oracle Virtualbox commands
- `vboxmanage list vms`
- `vboxmanage unregistervm <name or ID> –delete`
- what happens if you don't use `–delete`?
- `vboxmanage list hdds`
- `vboxmanage closemedium <UUID>`
- What happens if you edit `create_vm.yml` and change from '–type gui' to '–type headless'?

Try to add a local password for console login in case the VM is unable to get an IP address for SSH using certificates.

### Test on a Windows PC with Virtualbox Installed
In testing on Windows 11 Pro, some settings we used on Linux crash the installation. Specifically virtualization and nested hardware virtualization.

For Windows, use the file `testvm.bat` ([testvm.bat](testvm.bat))

You can also copy/paste the the command into the command prompt if you don't want to run the `.bat` file
