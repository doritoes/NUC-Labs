# Discover NUCs and add to Ansible inventory
We now have a stack of NUCs booted up and connected to a wireless network. Let's "discover", or add them to the Ansible inventory. This is how Ansible keeps track of the hosts that it will manage.

As the number of NUCs gets larger, it's more of a pain to track down the IP addresses. Then you have to add thoses hosts to the SSH known_hosts file. This script is one way to speed up the process.

⚠️ If you did some experimentation in the previous step, you may receive warnings about systems that have already been added.

## Copy the Discovery Script to NUC2
- From NUC 1, download [discover.sh](discover.sh)
- From NUC 1, at the terminal, enter
  - `scp Downloads/discover.sh ansible@[IP OF NUC2]:~/my-project/`

## Run the Discover Script on NUC2, the Ansible controller
- Log in to NUC2, the Anible control node
  - First, log in to NUC 1
  - From the terminal, enter `ssh ansible@[IP OF NUC2]`
- Run the script from NUC 2
  - `cd my-project`
  - `bash discover.sh hosts`
  - Wait as the script discovers systems on the local network running an SSH server
    - the more devices on the Lab network, the more devices to discover and try to connect to
- View the file
  - `cat hosts`
  - ⚠️ If you run the script multiple times, you can end up with duplicate lines in the file `hosts`
- If you need to modify text files, text editors `nano` and `vi` are installed

## Identify Nodes That Weren't Discovered
What if the hosts file doesn't list all the NUCs? Here is my trick.
- Power down all the nodes there were discovered
  - Log in to NUC 2 (ansible controller)
  - `ansible -i hosts all -a "shutdown -h now"`
- Pull any NUCs that are still powered on for troubleshooting or re-imaging
- Power the "good" NUCs back on

Note that the NUCS are somewhat slow to start up at this point. We will be fixing that shortly.

## Learn More
### Experiment the Ansible Environment
#### Check Nodes Are Up
A quick ansible "ping":
- ` ansible -i hosts all -m ping`
#### Discover NUC Board Names
You can view the board names of your NUCs. Just be aware that the board name can be different from the model number on the case.
- `ansible -i hosts all -msetup -a "filter=*board_name*"`
### Discovery Using LLDP
Another way to discover the NUCs on the network quickly and easily is to use lldp.

**NOTE**: lldp is a standards-based neighbor discovery protocol similar to Cisco CDP. It works fine over wired network connections. However, in my experience wireless routers and access points don't support lldp between wireless clients, so I have not included this in the lab.

To use lldp in a wired lab
- add the lldpd to the list of packages to install using apt
- install on NUC 1 using sudo apt install lldpd
- from NUC 1 run lldpcli show neighbors
