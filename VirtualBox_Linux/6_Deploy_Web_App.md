# Deploy Web App to our fleet of VMs
In this step will deploy a placeholder web application to the servers.

## Deploy a Demonstration App

### Create the application.yml file
- Create file `/home/ansible/application.yml` with contents of [application.yml](application.yml)

### Create the jinja (j2) Template for Nginx
- Create file `/home/ansible/app-conf.j2` with contents of [app-conf.j2](app-conf.j2)

### Deploy Nginx with PHP and Set up a Test App
- Create file `/home/ansible/application_fleet.yml` with contents of [application_fleet.yml](application_fleet.yml)
- Run the playbook
  - `ansible-playbook -i inventory application_fleet.yml`

## Test
- Open each VM IP address in a web browser and confirm you see the standard phpinfo() page, similar to the following
  - `http://<IPADDRESS>`
- Create file `/home/ansible/check_fleet.yml` with contents of [check_fleet.yml](check_fleet.yml)
- Run the playbook
  - `ansible-playbook -i inventory check_fleet.yml`

The playbook confirms a page with HTTP status 200 is returned (but not necessary the contents)

### Reboot the Servers 50% at a Time
- Create file `/home/ansible/reboot-half.yml` with contents of [reboot_half.yml](reboot_half.yml)
- Run the playbook
  - `ansible-playbook -i inventory reboot_half.yml`

### Shut the Servers Down Two Ways then Power On
This first method use's the OS shutdown command.
- Create file `/home/ansible/shutdown_fleet.yml` with contents of [shutdown_fleet.yml](shutdown_fleet.yml)
- Run the playbook
  - `ansible-playbook -i inventory shutdown_fleet.yml.yml`

Sending a power off signal using VirtualBox is a second way to gracefully power off the servers.
- Create file `/home/ansible/power_off_fleet.yml` with contents of [power_off_fleet.yml](power_off_fleet.yml)
- Run the playbook
  - `ansible-playbook -i inventory power_off_fleet.yml`

There is only one way to turn them back on, though.
- Create file `/home/ansible/start_fleet.yml` with contents of [start_fleet.yml](start_fleet.yml)
- Run the playbook
  - `ansible-playbook -i inventory start_fleet.yml`


## Rebuild Specific Servers
Let's say one of the servers has a problem and we want to rebuild it.
### Destroy Specific Servers
The simplest way is to modify the servers.yml file.

Set **Deploy** to **false** for <ins>the servers you don't want to touch</ins>, and leave Deploy as true for the ones you do. Then later you can set everything back to true. This is usually simpler than creating a new servers.yml file or modifying the scripts to use the new servers.yml file.

Run the playbook: `ansible-playbook destroy_fleet.yml`

Sometimes you will find that the server is down but still locked when the playbook goes to remove the VM. Re-running the playbook will remove it. How can you improve the playbook to reduce the likelihood of this happening?

What are the side effects of running the destroy_fleet.yml script this way? (Hint, what directories were removed? Instead of removing the entire working directory, how could you modify the destroy_fleet.yml playbook?)

### Re-Create Specific Servers
With the modified servers.yml file is it simple enough to re-create the server.

Run `ansible-playbook build_fleet.yml`

Because the working directory was removed, the ISO is freshly downloaded. This means if a new release came out, your new server could be different from the rest of the VMs.

### Reconfigure Specific Servers
Next we will run the configure_fleet.yml playbook on the specific server.

Run: `ansible-playbook -i inventory -l <IPADDRESS> configure_fleet.yml`

### Deploy the Application to Specific Servers
Use the same technique to deploy the application to the rebuilt server.

Run: `ansible-playbook -i inventory -l <IPADDRESS> application_fleet.yml`

### Test the Redeployed Server
Run `ansible-playbook -i inventory -l <IPADDRESS> check_fleet.yml`

## Learn More
The process does it's job but could be a lot better.

### Re-Applying Settings after Changing servers.yml
Because we are limited to running commands using vboxmanage instead of using a full integrated module, we can't modify VM resources to match an updated servers.yml. Rebuilding a server requires completely destroying it then re-creating it.

### Fragile Playbook configure_fleet.yml
A well-behaved playbook would update the configuration as needed if re-run.

What happens when you re-run ansible-playbook -i inventory configure_fleet.yml?

What tasks could be moved to the build_fleet.yml playbook? Look at fleet-user-data.j2 file. What additional late-commands would you add?

Alternatively, what error handling could you do in configure_fleet.yml? Note that the playbook only resizes filesystems when they are larger than a set amount. This is because trying to resize the default partition is already 10GB and would create an error. How can you better handle all cases?

Edit
Fragile Playbook applications_fleet.yml
Similarly, applications_fleet.yml causes problems when it is run again.

What happens when you re-run ansible-playbook -i inventory application_fleet.yml?

Log in to a VM and examine /var/www/html/index.php. Do you see duplicates of the block if text the playbook uses?

There are certainly better ways to deploy applications, just as using git.

Run this playbook as ansible-playbook -i inventory git_fleet.yml –ask-become

git_fleet.yaml
~~~~
---
- hosts: all
  become: true
  tasks:
    - name: Install Git
      apt:
        name: git
        state: present
        update_cache: true
    - name: Git clone project
      git:
        repo: https://github.com/doritoes/nuc-ansible-lab.git
        dest: "{{ lookup('env','HOME') }}/project"
        update: yes
~~~~
How could you deploy an application to the /var/www/html folder?
