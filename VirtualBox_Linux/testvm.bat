SET CM="C:\Program Files\Oracle\VirtualBox\VBoxManage"
SET VMN=my_vm
SET ISOP=C:\Tools\ubuntu-22.04-autoinstall.iso
SET ADAPTER=Intel(R) Wi-Fi 6E AX211 160MHz
 
%CM% list vms
 
%CM% createvm --name %VMN% --ostype Ubuntu_64 --register
%CM% createmedium disk --filename %VMN%.vdi --size 40960 --format=VDI
%CM% storagectl %VMN% --name IDE --add IDE --controller PIIX4
%CM% storageattach %VMN% --storagectl IDE --port 0 --device 0 --type dvddrive --medium "%ISOP%"
%CM% storagectl %VMN% --name SATA --add SAS --controller LsiLogicSas
%CM% storageattach %VMN% --storagectl SATA --port 0 --device 0 --type hdd --medium %VMN%.vdi
%CM% modifyvm %VMN% --boot1 disk --boot2 DVD --boot3 none --boot4 none
%CM% modifyvm %VMN% --cpus 2
%CM% modifyvm %VMN% --memory 2048
%CM% modifyvm %VMN% --vram 16
%CM% modifyvm %VMN% --graphicscontroller vmsvga
%CM% modifyvm %VMN% --hwvirtex off
%CM% modifyvm %VMN% --nested-hw-virt off
%CM% modifyvm %VMN% --ioapic on
%CM% modifyvm %VMN% --pae off
%CM% modifyvm %VMN% --acpi on
%CM% modifyvm %VMN% --paravirtprovider default
%CM% modifyvm %VMN% --nestedpaging on
%CM% modifyvm %VMN% --keyboard ps2
%CM% modifyvm %VMN% --uart1 0x03F8 4
%CM% modifyvm %VMN% --uartmode1 disconnected
%CM% modifyvm %VMN% --uarttype1 16550A
%CM% modifyvm %VMN% --macaddress1 auto
%CM% modifyvm %VMN% --cableconnected1 on
%CM% modifyvm %VMN% --nic1 bridged --bridgeadapter1 "%ADAPTER%"
%CM% modifyvm %VMN% --usbxhci on
%CM% startvm %VMN% --type gui
%CM% showvminfo %VMN%
