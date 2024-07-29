# Appendix - Install QEMU Guest Agent on Windows
Reference: https://pve.proxmox.com/wiki/Qemu-guest-agent#Windows

- Download the virtio-win drive ISO
  - https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
  - similar to virio-*.iso
- Mount the IOS file in the Windows VM 
- Open Device Manager
- Find PCI Simple Communications Controller
- Right glick -> Update Driver
  - Select the mounted ISO in  DRIVE:\vioserial\<OSVERSION>\ where <OSVERSION> is your Windows Version (e.g. 2k12R2 for Windows 2012 R2)
- Install qemu-guest-agent from the ISO you mounted
  - Navigate to directory guest-agent
  - Run `qemu-ga-x86_64.msi`
- Verify
  - From powershell `Get-Service QEMU-GA`
