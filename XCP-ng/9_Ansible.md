# Automation with Ansible
Automation with XCP-ng is centered around Ansible. In this Lab we look at ways to automated bringing up our Lab environment. It is easily adapted to shut down the environment. See the references for documentation on fully automating xcp-ng.

NOTE If you are looking at using Python, you might be able to adapt https://github.com/Stella-IT/XenGarden/tree/main

References:
- https://docs.ansible.com/ansible/latest/collections/community/general/xenserver_guest_module.html
- https://docs.ansible.com/ansible/latest/collections/community/general/xenserver_guest_powerstate_module.html

Preparing your Ansible workstation
- Run under WSL (Windows Subsystem for Linux) or on a Linux box
- `sudo apt update && sudo apt install -y ansible`
- `ansible-galaxy collection install community.general`
- `python3 -m pip install XenAPI`

Simple Playbook `poweronvm.yml`: `ansible-playbook poweronvm.yml`
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
  - name: Power on pen10
    community.general.xenserver_guest_powerstate:
      hostname: "{{ xenserver_hostname }}"
      username: "{{ xenserver_username }}"
      password: "{{ xenserver_password }}"
      name: pen10
      state: powered-on
    delegate_to: localhost
    register: facts
  - name: Power on pentest-workstation
    community.general.xenserver_guest_powerstate:
      hostname: "{{ xenserver_hostname }}"
      username: "{{ xenserver_username }}"
      password: "{{ xenserver_password }}"
      name: pentest-workstation
      state: powered-on
    delegate_to: localhost
    register: facts
~~~
