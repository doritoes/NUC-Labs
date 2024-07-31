# Appendix - Install QEMU Guest Agent on Windows
Reference: https://pve.proxmox.com/wiki/Qemu-guest-agent#Windows

These instructions did not work in Lab testing. The "PCI Simple Communications Controller" did not appear.

- Download the virtio-win drive ISO
  - https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
  - similar to `virtio-win-0.1.240.iso`
- Mount the ISO file in the Windows VM (right-click, then click Mount)
- Open Device Manager
- Find PCI Simple Communications Controller
  - ⚠️ Did not intially find this in device in Lab testing
    - This seemed to work: Installing agent from ISO, enable driver in proxmore, and full stop/start
    - It will eventually appear!
  - Right click PCI Simple Communications Controller -> Update Driver
    - Browse my computer for drivers
    - Select the mounted ISO in DRIVE:\vioserial\<OSVERSION>\ where <OSVERSION> is your Windows Version (e.g. 2k12R2 for Windows 2012 R2)
      - Example: E:\vioserial\w10\amd64\
- Install qemu-guest-agent from the ISO you mounted
  - Navigate to directory guest-agent
  - Run `qemu-ga-x86_64.msi`
- Verify service is running
  - From powershell `Get-Service QEMU-GA`
- Verify from proxymox
  - Log in to proxmox web GUI and find the VM's ID (for example, 102)
  - Log in to proxymox CLI and ping the VM's ID
    - `qm agent 102 ping`
  - No message means it was successful, "QEMU guest agent is not running" means it is failing
