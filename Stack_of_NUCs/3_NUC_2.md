# NUC 2
NUC 2 is the first server in our ["Stack of Nucs"](https://www.unclenuc.com/lab:stack_of_nucs:start)
- will be the Ansible control node
- build using the USB install and autoconfiguration method we tested

Ansible terms:
- Control node - A system on which Ansible is installed. You run Ansible commands such as ansible or ansible-inventory on a control node.
- Managed node - A remote system, or host, that Ansible controls.
- Inventory - A list of managed nodes that are logically organized. You create an inventory on the control node to describe host deployments to Ansible.

References:
- https://cloudinit.readthedocs.io/en/latest/reference/examples.html
- https://docs.ansible.com/ansible/latest/getting_started/index.html

Hardware:
- [[https://www.intel.com/content/www/us/en/products/sku/76978/intel-nuc-kit-d34010wyk/specifications.html|D34010WYK]] - i4-4010U @ 1.70GHz
  - Haswell NUC D34010WYK and D54250WYK: BIOS version 0054 (9/2/2019)
  - [[https://www.intel.com/content/www/us/en/download/17536/bios-update-wylpt10h.html]]
  - 8GB RAM
  - 32GB or more storage
  - Wireless card
  - About 10 old, but still readily available in used market

Software:
  * Ubuntu 22.04 LTS server

Purpose:
  * Ansible control node

## Modify the CIDATA USB stick for the Ansible Controller
These steps are performed while logged in to NUC1

## Boot NUC 2 with USB Sticks
- make sure NUC 2 is powered off
- connect the ethernet port to your lab network (which should have Internet access)
- no video, keyboard, or mouse are required (if everything goes as planned)
  - connect video if you need to do any troubleshooting
- insert both USB sticks
- power on NUC2
- press F10 when prompted and select the USB bootable USB stick (“USB UEFI”)
- wait patiently
  - if the user-data file is configured to update packages, be aware this requires additional time
  - if the ISO is older, it may take a while to download and install all the security updates
- when the NUC powers down the first time, <ins>remove the USB sticks</ins> and power it back on
- when the NUC powers down the second time, it is ready to deploy

## Prepare Ansible
By default, Ansible default configuration file and inventory file is located at /etc/ansible/ansible.cfg and /etc/ansible/hosts respectively.

- From NUC 1, log in to NUC 2 using ssh at the command line
  - `ssh ansible@[IP ADDRESS OF NUC2]` ([tip](https://learn.umh.app/course/connecting-with-ssh/))
- Generate keys
  - `ssh-keygen -o`
  - press enter to accept defaults for all prompts
- View the key, which you will use for building the remaining NUCs
  - `cat ~/.ssh/id_rsa.pub`
- Ansible is installed, but with no inventory file(s) or configuration
  - `ansible --version`
- Create some files for Ansible; we will be configuring/adding the new NUCs under `[nodes]` later
~~~
mkdir my-project
cat <<'EOF' > my-project/hosts
[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user='ansible'
ansible_become=yes
ansible_become_method=sudo
 
[nodes]
 
EOF
~~~

## Update NUC 2 Ubuntu Packages Remotely
- Type `exit` to exit back to your NUC 1 session
- Test running a remove command using SSH
~~~
ssh ansible@[IP ADDRESS NUC2] "sudo apt update && sudo apt upgrade -y"
~~~