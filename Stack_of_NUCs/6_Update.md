# Update and Configure
In this section we will use ansible playbooks to update our NUCS.

## Connect to the Ansible Control Node
From NUC 1, log in to the Ansible control node, NUC 2

## Disable the DNS Stub Resolver
Even though each node receives its DNS information via DHCP, Ubuntu 22.04 will at times fail to resolve names. Rebooting solves the problem temporarily, but it will come back.

This ansible playbook will fix this problem.
1. Create file `/home/ansible/my-project/disable-dns-stub.yml` with the contents of [disable-dns-stub.yml](disable-dns-stub.yml)
2. Run the playbook
    - `ansible-playbook -i hosts disable-dns-stub.yml`

  That was easy! Note that the task results in yellow show what was changed. If you run it again, you will see that the changes for the "Disable DNS stub listener" task weren't repeated, as no changes were required. But the restarts of NetworkManager and systemd-resolved are repeated.

## Faster Bootup Times with WiFi Only
Let's set the ethernet "wired" network interface to be "optional" on the nodes. Normally they wait for the LAN network to come up. Since these NUCs are Wifi-only, the LAN interface will never come up.

1. Create file `/home/ansible/my-project/ethernetoptional.yml` with the contents of [ethernetoptional.yml](ethernetoptional.yml)
2. Run the playbook
    - `ansible-playbook -i hosts ethernetoptional.yml`
  
## Reboot All Nodes
### Quick and Dirty
- Reboot module: `ansible -i hosts all -m reboot`
  - the command doesn't return until all the nodes are rebooted
- Remote ad hoc commmand: - `ansible -i hosts all -a "/sbin/reboot"`
  - connection error, but all are successfully rebooted
  - eventually get the reset of the connection errors
  - then the command returns when they are all back up

### Graceful 50% at a time reboot
This playbook reboots the Nodes 50% at a time, waiting for the first group of servers to come up before rebooting the next group. This is technique that will come in handy in later Labs.

1. Create file `/home/ansible/my-project/reboot-half.yml` with the contents of [reboot-half.yml](reboot-half.yml)
2. Run the playbook
    - `ansible-playbook -i hosts reboot-half.yml`

Watch the playbook run. If you'd like, try the playbook without the line `serial: "50%"`.

## Update Ubuntu Packages on all Nodes
This playbook update all the software pages on all the nodes.

1. Create file `/home/ansible/my-project/update.yml` with the contents of [update.yml](update.yml)
2. Run the playbook
    - `ansible-playbook -i hosts update.yml`

Watch as the playbook updates the apt repo, upgrades packages, and reboots if necessary.

If you run it again, note that no changes where made. Everything was up to date.
