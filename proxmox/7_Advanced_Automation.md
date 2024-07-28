# Advanced Automation with proxymox.
Proxmox does not ship with Ansible, but you can install it on the host. This example is based on the example by [fatzombi](https://medium.com/@fat_zombi).

TIP: Support fatzombi [here](https://www.buymeacoffee.com/fatzombi)

Reference: https://www.reddit.com/r/homelab/comments/13u66yn/automating_your_homelab_with_proxmox_cloudinit/
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-introduction-6a95ee3e57a
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-part-1-configuring-a-448576621edd?sk=efe413d550cc0cac162463b804e18577
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-part-2-deploying-your-a7de6caa64b7?sk=ef40743f7886f50cc1f121d818605c22
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-part-3-automating-with-23acc2343340?sk=3f7023f29dc560b41bd97f3221e08c0b

NOTES
- This lab is performned on the proxmox host itself
- You will need a subscription or have installed the no-subscription repository

# Prerequisites
- `apt update && apt install -y libguestfs-tools`

# Create Base Image with Cloud-init

## Download Ubuntu 22.04 Server ISO
Free free to customize this lab and use 24.04! If you already have your favorite Ubuntu Server ISO uploaded to local storage, you can skip to the next step. Be aware we will be customizig this ISO.

Steps
- Select the version you want from https://releases.ubuntu.com for https://ubuntu.com/download/server
  - Find the link on the releases site that is suitable for use with wget (see example below)
- `cd /var/lib/vz/template/iso/`
- `wget https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso`

## Customize the Base Image
We wish to install qemu-guest-agent on the VMs that use our Cloud-init image.
- `virt-customize -a ubuntu-22.04.4-live-server-amd64.iso --install qemu-guest-agent`
- virt-customize: error: no operating systems were found in the guest image

# Create Template
NOTE This template uses **vmbr0**, which puts the VM on the Lab network, not behind our router or firewall. Change this to vmbr1 for the "Inside" network, or vmbr2 for the "Pentesting" network.
~~~
qm create 9001 --name "ubuntu-22.04-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9001 ubuntu-22.04.4-live-server-amd64.iso local-lvm
qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9001-disk-0
qm set 9001 --boot c --bootdisk scsi0
qm set 9001 --ide2 local-lvm:cloudinit
qm set 9001 --serial0 socket --vga serial0
qm set 9001 –-agent 1
qm template 9001
~~~
