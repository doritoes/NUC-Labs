# Folding at Home (FAH or F@H)
Let's kick up the Lab another notch and demostrate running [Folding at Home (FAH)](https://foldingathome.org/]) on the worker nodes. I updated the playbook by ajacocks to add the current FAH release and hack up a quick fix.

💡What is Folding At Home? It's a way to donate CPU and/or GPU cycles to help cure diseases. Your computer will simulate protein dynamics, including the process of protein folding.

Please note that the NUCs I am using for this lab have only 4 cores, and for some WU's (work units) the client will only use 3 cores. So don't expected to be scoring many points with these small boxes. But more powerful NUCs do well and are power efficient. HOWEVER beware you can lose/wear out your cooling fan. NUCs aren't built for running the cooling fan all the time.

Purpose:
- Demonstrate a running a complex workload of a service combined with configuration files

Current issues:
- working on improving getting FAH to work more directly
  - can we fix the multiple processes issue?
  - can we improve the initial config.xml installation?

References
- https://github.com/ajacocks/fah
- https://github.com/aisbergg/ansible-role-lm-sensors

## Install the fahcontrol app on NUC 1
The official download [here](https://foldingathome.org/alternative-downloads/?lng=en) does not work with Ubuntu 22.04. The snap store has a snap for FAH but the control application doesn't work.

Use https://github.com/cdberkstresser/fah-control
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
- Change directory to `/home/ansible/my-project/fah`
- Modify file `/home/ansible/my-project/fah/inventory`
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

You would expect the build to be complete here. However I have observed:
  - two instances of FAH running
  - the configuration we installed getting overwritten with a default configuration

Therefore we are going to re-apply the configuration and reboot the nodes:
- Create file /home/ansible/my-project/fah/reconfigure-fah.yml with the contents of [reconfigure-fah.yml](fah/reconfigure-fah.yml)
- Run the playbook
  - `ansible-playbook reconfigure-fah.yml`
  - Note: see how the fah directory's inventory file is used
- Reboot the nodes
  - `ansible all -m reboot` 

⚠️ It seems that running the "main.yml" playbook on an already configured system will run multiple copies of FAH and cause the major  problems. Rebooting solves the issue: ''ansible -i hosts all -m reboot''

## Check FAH node status
- Change directory to /home/ansible/my-project
- Create file /home/ansible/my-project/fah/check-fah-status.yml with the contents of [check-fah-status.yml](fah/check-fah-status.yml)
- Run the playbook
  - `ansible-playbook check-fah-status.yml`

## Check the config file on each node using ansible
- Create file /home/ansible/my-project/fah/check-fah-config.yml with the contents of [check-fah-config.yml](fah/check-fah-config.yml)
- Run the playbook
  - `ansible-playbook check-fah-config.yml`

The configuration will now match your expected settings which you entered in the `inventory` file. If the configuration is not correct, see the reconfigure-fah.yml playbook above.

## Add the folding nodes to fahcontrol
- On NUC 1, open the FAHControl program
  - Open the terminal
  - `cd fah-control`
  - `./FAHControl`
- Addclients one at a time in FAHControl
  - At the bottom of the "Clients" pane on the left, Click **Add**
    - Any name you want
    - IP address of the client
    - Control password you used in the **inventory** file on the Ansible console server (NUC2)
      - `/home/ansible/fah/inventory`

If you cannot connect with the control app and/or you see an error regarding a locked database, reboot the node to clear the error.

## Work with the stack of FAH Clients
### Work with FAH Commands
- Check points per day (PPD) and queue information:
  - `ansible all -a "FAHClient --send-command ppd"`
  - `ansible all -a "FAHClient --send-command queue-info"`
- Tell all nodes to finish their work unit then pause
  - `ansible all -a "FAHClient --send-command finish"`
  - It's good form to finish the work units that are assigned to you before removing FAH from the nodes
- Pausing and unpausing folding
  - `ansible all -a "FAHClient --send-pause"`
  - `ansible all -a "FAHClient --send-unpause"`

NOTE that if you pause folding, or it is pausing after finishing folding a unit, some of the playbooks below will error out. There is no data to display.

### Check Queue State
- Create file /home/ansible/my-project/fah/check-fah-queue.yml with the contents of [check-fah-queue.yml](fah/check-fah-queue.yml)
- Run the playbook
  - `ansible-playbook check-fah-queue.yml`
Understanding results:
- Test fails if queue is empty
- Status READY if node has paused folding
- Status RUNNING if node is folding

### Check Work Unit ETAs
Show time to completion for the current queue item.
- Create file /home/ansible/my-project/fan/check-fah-eta.yml with the contents of [check-fah-eta.yml](fah/check-fah-eta.yml)
- Run the playbook
  - `ansible-playbook check-fah-eta.yml`
Understanding results:
- Test fails if queue is empty
- Test fails if folding is paused
- Otherwise returns the estimated time remaining to complete the current work unit (WU) in the queue

### Check CPU Utilization
Check the CPU load on the nodes
- Create file /home/ansible/my-project/fah/check-fah-cpu.yml with the contents of [check-fah-cpu.yml](fah/check-fah-cpu.yml)
- Run the playbook
  - `ansible-playbook check-fah-cpu.yml`

Understanding results:
- CPU information is returned
  - User CPU (percentage of CPU utilization while executing at the user, or application, level)
  - System CPU (percentage of CPU utilization while executing at the system, or kernel, level)
  - Nice CPU (percentage of CPU utilization while executing at the user level with nice priority)
  - The sum total is the current CPU utilization

### Check Temperature
1. Install lm-sensors package
    - Option 1 - Ad Hoc
      - `ansible -i hosts all -m apt -a "name=lm-tools state=present"`
    - Option 2 - Playbook
      - Create file /home/ansible/my-project/fah/lm-sensors.yml with the contents of [lm-sensors.yml](fah/lm-sensors.yml)
      - Run the playbook
        - `ansible-playbook lm-sensors.yml`
2. Check Temerature
    - Ad Hoc
      - `ansible all -a sensors`
      - `ansible all -a "sensors -j"`
    - Playbook
      - Create file /home/ansible/my-project/check-fah-temps.yml with the contents of [check-fah-temps.yml](fah/check-fah-temps.yml)
      - Run the playbook
        - `ansible-playbook check-fah-temps.yml`
        - It will fail if the CPU package temperature is over 80C (176F)
Learn more about "how hot is too hot?" by looking at the detailed output from `ansible all -a "sensors -j"`
- input: current temperature in C
- max: the maximum seen temperature in C
- crit: at what point the temperate reaches a critical level
- to view in Fahrenheight: `ansible all -a "sensors -j -f"`
- it's not uncommon to see the max temperatore over 80C, but still far short of the critical temperature

Learn more about using lm-sensors with Ansible: https://github.com/aisbergg/ansible-role-lm-sensors

## Remove FAH
Before you remove FAH and move on, why not look at how many points your username earned from Folding?
- https://stats.foldingathome.org/
- Search for the name you selected
- If you want to keep folding, Team NUC is always looking for members
  - https://stats.foldingathome.org/team/1061684
  - https://folding.extremeoverclocking.com/team_summary.php?s=&t=1061684

Now we are going to disable the service and uninstall it. In the previous steps there was an optional step to “finish folding”. Bonus points for doing this before you remove FAH.
- From NUC 1, log in to the Ansible control node, NUC 2
- Change directory to /home/ansible/my-project
- Create file /home/ansible/my-project/remove-fah.yml with the contents of [remove-fah.yml](fah/remove-fah.yml)
- Run the playbook
  - `ansible-playbook remove-fah.yml`
