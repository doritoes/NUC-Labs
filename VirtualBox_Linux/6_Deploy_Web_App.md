# Deploy Web App to our fleet of VMs
In this step will deploy a placeholder web application to the servers.

🚧 Continue building here...

## Deploy a Demonstration App

### Create the application.yml file
### Create the jinja (j2) Template for Nginx

### Deploy Nginx with PHP and Set up a Test App

## Test

### Reboot the Servers 50% at a Time

### Shut the Servers Down then Power On Two Ways

## Rebuild Specific Servers
### Destroy Specific Servers
### Re-Create Specific Servers
### Reconfigure Specific Servers
### Deploy the Application to Specific Servers



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
