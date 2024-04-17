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
   
  🚧 To be continued...
