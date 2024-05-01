# Host Installation and Configuration
You will need to set up a large-ish Ubuntu system. This will be home to the Oracle VirtualBox virtual machines (VM's). You can use any Ubuntu system, but you get points for using a NUC. This system will also be the Ansible controller for this lab.

## Install Ubunutu 22.04 Desktop
The first step is to install Ubuntu 22.04 Desktop on the host system. It's a good idea to use a “minimal installation” of Ubuntu for this Lab. If you need help with this step, see the tutorial below. Since this is a Lab, sometimes break and it's really helpful to be able to use the Oracle VirtualBox GUI to access the consoles of your VMs.

*See Tutorial: [Install Ubuntu Desktop](https://ubuntu.com/tutorials/install-ubuntu-desktop#1-overview)*

## Update and Install Packages
- Once installation is complete, log in and follow brest practies to upgrade software packages on the system
  - Open a Terminal
  - `sudo apt update && sudo apt upgrade -y`
- Install the `ppa:ansible` repository
  - `sudo apt-add-repository ppa:ansible/ansible`
  - `sudo apt update`
- Install requried packages
  - `sudo apt install -y openssh-server vim ansible p7zip-full xorriso ansible python3-passlib`

You should now be able to SSH to your Host.

*See Tutorial: [Enable SSH](https://linuxize.com/post/how-to-enable-ssh-on-ubuntu-20-04/)*

## Configure User ansible
*See Tutorial: [How to Create Users in Linux (useradd command)](https://linuxize.com/post/how-to-create-users-in-linux-using-the-useradd-command/)
1. Create the user ansible and grant it sudo permissions. Enter a password for the user when prompted.
~~~~
sudo useradd -m -s /bin/bash ansible
sudo usermod -aG sudo ansible
sudo passwd ansible
~~~~
2. Test the new user
    - From your regular login switch the `ansible` user
      - `su - ansible `
      - *enter the password*
      - `sudo uptime`
      - `exit`
    - Test connecting to your host from other systems via SSH with the `ansible` user

## Generate Keys for Management
1. Ensure you are logged in as the user `ansible`
2. Create the keys
    - `ssh-keygen -o`
    - <ins>Do not</ins> enter a passphrase
    - Accept all defaults (press enter)
3. View the public key ans <ins>save it for a later step</ins>
    - `cat ~/.ssh/id_rsa.pub`
    - Looks similar to:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKwEYxgppj+um+/W8LLxRpwZ2887IJirfJjFBkE30UeCZ0D1JS2RTMn4QEK1EAphByGxnmCruTL36aLMTO0FNH4IW+017/7wNY4JjRzRssZSMqmdjH4nhYV22JDIWh428p93FLsgqM+ud0Mj06KgJfa4BQtSvnR/p/4AXYzFTwzE+kyussIiOi+uT20AXNEIxk4ps39xhLGc6XNFo1xhtGvTZ9+Jx7AanVht090HuRuxNmOTd260mbeBJUKRF57d9tzZ68YRQiokIunkNF2skfJOZEUaIOWUoGGIWPMlEUEC0RhyW+7Ljmp7RbIOZ45CV0MYZEpKx4KQ61/CoMY4wKBCM90SwxJQwM3CZCseqcVnpFYKpFd6dnn0v0XsmINCU+y1RXYLfsOHEhLTm5WK9ERi5yr/1OjKkId+xZrf7D/v2soQdHsc82d+otbTDXzHYPduc2DfstJg5QFCECNrsEPRishAh2Lm2GJ3h0Pj20loyYeKWlUJpbLjd5A5Mnk9E= ansible@labserver

## Install Oracle Virtual Box
We are going to use Ansible to install Oracle VirtualBox

**NOTE** There are many references out there if you don't want to use Ansible to install VirtualBox (e.g., https://linuxconfig.org/install-virtualbox-on-ubuntu-22-04-jammy-jellyfish-linux)

1. Copy the playbook `install-virtualbox.yml` ([install-virtualbox.yml](install-virtualbox.yml)) to your home directory
2. Run the playbook `ansible-playbook install-virtualbox.yml --ask-become-pass`
    - Enter the password for the user `ansible` when prompted

## Restart the Host
Reboot the Host and wait or it to come back up.
