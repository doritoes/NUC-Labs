# Appendix - Display Resolution
Windows VMs booting with UEFI have a fixed display size. You can't change the screen resolution from Windows. Here is how to increase the screen resolution by modifying a BIOS setting
- First, in Xen Orchestra (XO), modify the VM advanced settings to increase Video RAM from 8MB to 16MB
- Open the console of the virtual machine.
- Start the virtual machine
  - as soon as possible, keep continuously pressing F2 until the UEFI setup screen appears
  - this may take a few tries
- Open **Device Manager**
- Open **OVMF Platform Configuration**
- Select **Change Preferred**
- Select the preferred resolution you want (1440 x 900 for example)
  - 1366 x 768 - don't use - scrambled video
  - 1440 x 900
  - 1600 x 900
  - 1920 x 1080
- Select **Commit Changes and Exit**
- Press **Esc**
- Select **Reset**
- Log in to Windows
  - Check windows Display settings and note the display resolution has changed
