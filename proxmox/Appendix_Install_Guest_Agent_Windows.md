# Appendix - Install QEMU Guest Agent on Windows
Reference: https://pve.proxmox.com/wiki/Qemu-guest-agent#Windows

🆕 See video https://www.youtube.com/watch?v=gWkqdVb4jp8

VirtIO Drivers location: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

Lab tested with Windows 10, Windows 11, Server 2022, and Server 2025.

- Download the virtio-win drive ISO
  - https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
  - similar to `virtio-win-0.1.240.iso`
- Inside proxmox select the VM, then Options
  - Confirm "QEMU Guest Agent" is enabled/checked (ahead of time if possible)
  - If you just enabled it, stop and start the VM
- Mount the ISO file in the Windows VM (right-click, then click Mount)
  - When building Windows servers in proxmox, there is an option to automatically mount the virtio CD
- Open Device Manager
- Find PCI Simple Communications Controller
  - If you don't see it, make sure QEMU Guest Agent is enabled in proxy, and power off/on (<i>not just reoot</i>)
  - Right click PCI Simple Communications Controller -> Update Driver
    - Browse my computer for drivers
    - Select the mounted ISO in DRIVE:\vioserial\<OSVERSION>\ where <OSVERSION> is your Windows Version (e.g. 2k12R2 for Windows 2012 R2)
      - Example: E:\vioserial\2k12R2\amd64\
- TIP You can install drivers for any remaining unrecognized devices using the same method
- Install qemu-guest-agent from the ISO you mounted
  - Navigate to directory guest-agent
  - Run `qemu-ga-x86_64.msi`
- Verify service is running
  - From powershell `Get-Service QEMU-GA`
- Verify from proxymox
  - Log in to proxmox web GUI and find the VM's ID (for example, 102)
  - Log in to proxymox CLI and ping the VM's ID
    - `qm agent 102 ping`
  - No message means it was successful; "QEMU guest agent is not running" means it is failing
