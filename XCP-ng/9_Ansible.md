# Automation with Ansible
Automation with XCP-ng is centered around Ansible. In this Lab we look at ways to automated bringing up our Lab environment. It is easily adapted to shut down the environment. See the references for documentation on fully automating xcp-ng.

NOTE If you are looking at using Python, you might be able to adapt https://github.com/Stella-IT/XenGarden/tree/main

References:
- https://xen-orchestra.com/blog/virtops3-ansible-with-xen-orchestra/
- https://docs.ansible.com/ansible/latest/collections/community/general/xenserver_guest_module.html
- https://docs.ansible.com/ansible/latest/collections/community/general/xenserver_guest_powerstate_module.html

Preparing your Ansible workstation
- We are going to use Ansible on `ubuntu-xo`. You can also run under WSL (Windows Subsystem for Linux) or on a Linux box
- `sudo apt update && sudo apt install -y ansible python3-pip python3-full`
- `ansible-galaxy collection install community.general`
- Install pip package XenAPI
  - Prior to Ubuntu 24.04
    - python3 -m pip install XenAPI
  - Ubuntu 24.04 and later quick and dirty
    - `pip install --break-system-packages XenAPI`
  - Installing "nicely" broken my ansible playbooks running
    - `python3 -m venv ~/venv`
    - `source ~/venv/bin/activate`
    - `pip install XenAPI`

# Ansible to the XCP-ng Host
Simple Playbook `poweronvm.yml`: `ansible-playbook poweronvm.yml`. Provide the credentials by variables or simple put the values directly into the playbook for this test.
~~~
---
- hosts: localhost
  tasks:
  - name: Power on opnsense
    community.general.xenserver_guest_powerstate:
      hostname: "{{ xenserver_hostname }}"
      username: "{{ xenserver_username }}"
      password: "{{ xenserver_password }}"
      name: opnsense
      state: powered-on
    delegate_to: localhost
    register: facts
~~~

Other states:
- powered-off
- restarted
- shutdown-guest
- reboot-guest
- suspended
- present (default)

Note that "reboot-guest" and "shutdown-guest" will fail if xen tools is not installed on the VM.

More advanced playbook that powers on the `opnsense` firewall, waits for it to come up, then powers on the VMs on the penstesting network. "Waiting for an IP address" requires the xen tools be installed. Replace with the correct IP address and credentials.

~~~
---
- hosts: localhost
  vars:
    - xenserver_hostname: 192.168.1.20
    - xenserver_username: root
    - xenserver_password: thesupersecretpasswordgoeshere
  tasks:
  - name: Power on opnsense
    community.general.xenserver_guest_powerstate:
      hostname: "{{ xenserver_hostname }}"
      username: "{{ xenserver_username }}"
      password: "{{ xenserver_password }}"
      name: opnsense
      state: powered-on
      wait_for_ip_address: true
    delegate_to: localhost
    register: facts
  - name: Power on penwin10
    community.general.xenserver_guest_powerstate:
      hostname: "{{ xenserver_hostname }}"
      username: "{{ xenserver_username }}"
      password: "{{ xenserver_password }}"
      name: penwin10
      state: powered-on
    delegate_to: localhost
    register: facts
  - name: Power on pentest workstation
    community.general.xenserver_guest_powerstate:
      hostname: "{{ xenserver_hostname }}"
      username: "{{ xenserver_username }}"
      password: "{{ xenserver_password }}"
      name: kali
      state: powered-on
    delegate_to: localhost
    register: facts
~~~

# Ansible to the XO
XCP-ng API is also called XAPI.

🌱 I am looking to document how to do the same simple tasks using Ansible and XAPI.
- https://xcp-ng.org/forum/topic/11547/ansible-and-xapi-first-playbook-ansible
