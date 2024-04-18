# Folding at Home (FAH or F@H)
Let's kick up the Lab another notch and demostrate running [Folding at Home (FAH)](https://foldingathome.org/] on the worker nodes.

I updated the playbook by ajacocks to add the current FAH release and hack up a quick fix.

Please note that the NUCs I am using this lab have only 4 cores, and for some WU's (work units) the client will only use 3 cores. So don't expected to be scoring many points with these small boxes.

Purpose:
- Demonstrate a running a complex workload of a service combined with configuration files

Current issues:
- working on improving terminating all instances when installing the fahclient.service
- work on improving config.xml file file getting installed correctly

References
- https://github.com/ajacocks/fah
- https://github.com/aisbergg/ansible-role-lm-sensors

## Install the fahcontrol app on NUC 1
The official download [here](https://foldingathome.org/alternative-downloads/?lng=en) does not work with Ubuntu 22.04. The snap store has a snap for FAH but the control application doesn't work.

Use [https://github.com/cdberkstresser/fah-control].
- Open a terminal window on NUC 1
- Install packages
  - `sudo apt-get install -y python3-stdeb python3-gi python3-all python3-six debhelper dh-python gir1.2-gtk-3.0`
- Clone the repo
  - `git clone https://github.com/cdberkstresser/fah-control.git`
- Set the version
  - `cd fah-control`
  - `echo "version = '7.7.0'" > fah/Version.py`
- Run the program
  - `./FAHControl`
Later we will use this control application to monitor and manage the workers.

## Install the FAH client on working nodes using Ansible
From NUC 1, log in to the Ansible control node, NUC 2
- Change directory to /home/ansible/my-project
-  Clone the client from this repository
  - `git clone --branch support-7-6-21 https://github.com/doritoes/fah.git`
- Change directory to ''/home/ansible/my-project/fah''
- Modify file ''/home/ansible/my-project/fah/inventory''
  - `[clients]`
    - copy your ansible node IPs from the file /home/ansible/my-project/hosts to the [clients] section
  - `[all:vars]`
    - chost='(IP of Control Node)'
      - the IP address of NUC, which will run fahcontrol
    - cpass='(control-node-password)'
      - enter a password here, ex. fahpass24
    - username='(Yourname @ folding@home)'
      - Choose a name to fold under, or use "Anonymous"
    - team=''
      - enter a FAH team number if desired
    - passkey='(redacted passkey from folding@home)'
      - if you have a passkey from F@H, enter it here; otherwise leave blank '' 
- Run the playook
  - `ansible-playbook main.yml`
  - if you encounter a DNS lookup failure on some or all nodes
     - your wireless router should be setting DNS information as part of DHCP
     - did you disable the DNS stub resolver in earlier steps?

## Check FAH node status
- Change directory to /home/ansible/my-project
- Create file /home/ansible/my-project/check-fah-status.yml with the contents of [check-fah-status.yml](check-fah-status.yml)
- Run the playbook
  - `ansible-playbook -i hosts check-fah-status.yml``

⚠️ All the nodes are running FAH and folding, but there are issues!
- our desired configuration file in /etc/fahclient/config.xml is actually in /var/lib/fahclient/configs/config-[datestamp].xml. The /etc/fahclient/config.xml is a default file without our configuration.
- Compare the logs in /var/lib/fahclient/logs with /var/lib/fahclient/log.txt
  - the database lock indicates two copies of FAH are running
  - Run `ps -ef` to see all the processes and locate the 2 processes
- 
It seems that running the playbook on an already configured system will run multiple copies of FAH and cause the major  problems. Rebooting solves the issue: ''ansible -i hosts all -m reboot''

## Add the folding nodes to fahcontrol
- On NUC 1, open the FAH control program
  - Add clients one at a time in FAHControl
    - Any name you want
    - IP address of the client
    - Control password you used configuring FAH

  - if you cannot connect with the control app and/or you see an error regarding a locked database
    - reboot the node to clear the error


troubleshotting
- Reboot all the clients to ensure the service registers properly and no double processes are running
  -  ''ansible clients -m reboot''
  -  If you want to confirm your FAH configuration copied correctly, see the optional section below


🚧 To be continued...

## Work with the stack of FAH Clients
### Check FAH Status
ansible-playbook check-fah-status.yml

### Work with FAH Commands
- Check points per day (PPD) and queue information:
  - `ansible clients -a "FAHClient --send-command ppd"`
  - `ansible clients -a "FAHClient --send-command queue-info"`
- Tell all nodes to finish their work unit then pause
  - `ansible clients -a "FAHClient --send-command finish"`
  - It's good form to finish the work units that are assigned to you before removing FAH from the nodes
- Pausing and unpausing folding
  - `ansible clients -a "FAHClient --send-pause"1
  - `ansible clients -a "FAHClient --send-unpause"`

### Check Queue State
### Check Work Unit ETAs
### Check CPU Utilization
### Check Temperature

## Remove FAH
Now we are going to disable the service and uninstall it. In the previous steps there was an optional step to “finish folding”. Bonus points for doing this before you remove FAH.

- From NUC 1, log in to the Ansible control node, NUC 2
- Change directory to /home/ansible/my-project
- Create file /home/ansible/my-project/remove-fah.yml with the contents of [remove-fah.yml](remove-fah.yml)
- Run the playbook
  - `ansible-playbook -i hosts remove-fah.yml``
