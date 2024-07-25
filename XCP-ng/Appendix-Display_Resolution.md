# Appendix - Display Resolution
Windows VMs booting with UEFI have a fixed display size. You can't change the screen resolution from Windows. Here is how to increase the screen resolution by modifying a BIOS setting
- Firt, in Xen Orchestra (XO), modify the VM advanced settings to increase Video RAM from 8MB to 16MB
- Open the console of the virtual machine.
- Start the virtual machine
  - as soon as possible, keep continuously pressing F2 until the UEFI setup screen appears
  - this may take a few tries
- Open **Device Manager**
- Open **OVMF Platform Configuration**
- Select **Change Preferred**
- Select the preferred resolution you want (1600x900 for example)
- Select **Commit Changes and Exit**
- Press **Esc**
- Select **Reset**
- Check Windows Display settings and note the display resolution has changed
