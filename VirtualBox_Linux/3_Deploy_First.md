# Deploy First VM
In this step you will create a playbook to deploy an Ubuntu server using Virtualbox.

## Create Playbook
NOTE This playbook expects you to run it on Ubuntu desktop host an open  a GUI.

- Create playbook `create_vm.yml` from this repo ([create_vm.yml](create_vm.yml))
- Run the Playbook
  - `ansible-playbook create_vm.yml`
- Watch the server build in the Virtualbox GUI app 

 
## Learn More
### Authentication
From inside the VM's console (in VirtualBox) try to log in as user `ansible`
- Does it work?

### Experiment with Oracle Virtualbox commands
- `vboxmanage list vms`
- `vboxmanage unregistervm <name or ID> –delete`
- what happens if you don't use `–delete`?
- `vboxmanage list hdds`
- `vboxmanage closemedium <UUID>`
- What happens if you edit `create_vm.yml` and change from '–type gui' to '–type headless'?

### Test on a Windows PC with Virtualbox Installed
In testing on Windows 11 Pro, some settings we used on Linux crash the installation. Specifically virtualization and nested hardware virtualization.

For Windows, use the file `testvm.bat` ([testvm.bat](testvm.bat))

You can also copy/paste the the command into the command prompt if you don't want to run the `.bat` file
