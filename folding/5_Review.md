# Review
This this lab we experienced
- configuring an Ubuntu Server, booting it from a USB stick
- installing an application using a .deb (Debian) package in Ubuntu
- monitoring the temperature a NUC

This lab introduced you to the concept used to boot servers in Oracle VirtualBox, VMware workstation, and production environments.
1. Procure the boot image (usual an .ISO image)
2. Mount it to the virtual machine (like how we plugged the USB stick into the NUC)
3. Power on the VM while telling it to boot from the image (like how we pressed F10 on the NUC to get to the boot screen)

Hopefully you will never have to use `dpkg` airectly again! Recently, `apt` got the ability to install .deb packages files directly.  Use `apt`, which uses `dpkg` under the hood and handles package depenies for you.

## Next Steps
- Do you have 4 or 5 NUCs handy? Take a look at the [Stack of NUCs](/Stack_of_NUCs/REAME.md) lab.
- Do you have a more recent and powerful NUC? Take a look at the [Kubernetes_App_Lab](/Kubernetes_App_Lab/README.md).
