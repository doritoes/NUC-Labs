# Create USB Sticks
Create the modified ISO for USB installation of remaining NUCs. These steps are performed while logged in to NUC1.

💡 You can open these instructions from NUC1 for your convenience.

## Download Server ISO
- Download the latest <ins>live-server</ins> ISO from the [Ubuntu 22.04 releases page](https://releases.ubuntu.com/22.04/)
  - Named similar to ubuntu-22.04.4-live-server-amd64.iso
- Move the ISO file to your home directory (e.g. /home/ubuntu/)

## Install livefs-editor
- Open the terminal (should be in your home directory by default)
- Install livefs-editor, which will be used to modify the ISO
~~~~
git clone https://github.com/mwhudson/livefs-editor
cd livefs-editor
sudo python3 -m pip install .
~~~~
- Return to your home directory (`cd ~` or `cd ..`)

## Create modified live-server ISO
- Update the following ORIG_ISO filename to match the actual file you downloaded
~~~~
export ORIG_ISO="ubuntu-22.04.4-live-server-amd64.iso"
mkdir mnt
sudo mount -o loop ${ORIG_ISO} mnt
cp --no-preserve=all mnt/boot/grub/grub.cfg /tmp/grub.cfg
sudo umount mnt
sed -i 's/linux	\/casper\/vmlinuz  ---/linux	\/casper\/vmlinuz autoinstall quiet ---/g' /tmp/grub.cfg
sed -i 's/timeout=30/timeout=1/g' /tmp/grub.cfg
export MODDED_ISO="${ORIG_ISO::-4}-modded.iso"
sudo livefs-edit $ORIG_ISO $MODDED_ISO --cp /tmp/grub.cfg new/iso/boot/grub/grub.cfg
~~~~

## Create bootable USB stick from the modified ISO
Use [Balena Etcher](https://www.balena.io/etcher) or [Startup Disk Creator](https://ubuntu.com/tutorials/create-a-usb-stick-on-ubuntu#1-overview)

### BalenaEtcher
🏗️ Improve this section
- Download Etcher for Linux x64 (64-bit) (AppImage)
- In a terminal, assign executable permissions to the downloaded file, extract and run it
  - For example, if the file is named `balenaEtcher-1.18.11-x64.AppImage`
  - `sudo chmod +x Downloads/balenaEtcher-1.18.11-x64.AppImage`
  - `sudo Downloads/balenaEtcher-1.18.11-x64.AppImage --appimage-extract`
  - `Downloads/balenaEtcher-1.18.11-x64.AppImage`
- Follow the same steps to create a bootable USB stick

### Startup Disk Creator
⚠️ Warning: In my Lab, the Startup Disk Creator would not recognize the modded ISO image. Just use BalenaEtcher.
- Insert the USB stick that you are doing to write
- From the desktop menu, find and start **Startup Disk Creator**
- Click **Other**, then select the newly created "modded" ISO file
- Click **Make Startup Disk**

## Create the CIDATA USB stick
Create a USB stick named CIDATA as a cloud-init datasource
- Unplug the bootable USB stick you just created
- Plug in the USB that will be erased and used as the cloud-init datasource
- Identify the USB stick device name
  - `lsblk`
  - Look for "sdb"
    - "sda" is usually your system drive, don't touch that one!
    - "sdb" will have the same size as your USB stick
- Format the USB stick - this example assumes it's "sdb"
  - Unmount partition that Ubuntu automatically mounted: `sudo umount /dev/sdb1`
  - Format it:  `sudo mkfs.vfat -I -F 32 -n 'CIDATA' /dev/sdb`
  - Confirm: `ls /dev/disk/by-label/`
- Create `meta-data` and `user-data` files on CIDATA  - this example assumes it's "sdb"
~~~~
mkdir /tmp/cidata
sudo mount /dev/sdb /tmp/cidata
sudo touch /tmp/cidata/meta-data
sudo touch /tmp/cidata/user-data
touch meta-data
touch user-data
~~~~
- Modify the user-data file on CIDATA
  - You can create the use using a text editor (notepadqq was installed earlier) or use the command line. However you will need root permissions. It might be simplest to use notepadqq to create the file in your home directory then `sudo cp user-data /tmp/cidata/`
  - ⚠️ Replace the key(s) in the example with the output from your computer for
   - `cat ~/.ssh/id_rsa.pub`
  - ⚠️ Replace the WiFi SSID name and PASSWORD with your WiFi SSID and passphrase
  - The example file: [user-data](user-data)
  - Unmount the USB stick
    - `cd ~`
    - `sudo umount /dev/sdb`
- You can now safely remove the USB stick
  
## Create the firmware upgrade USB stick
This step is optional. If you haven't already upgraded the firmware on your NUC to the latest version, here are the steps.
- Learn about upgrading the firmware
  - Read https://www.intel.com/content/www/us/en/support/articles/000005636/intel-nuc.html
  - https://www.unclenuc.com/lab:preparing_nucs_for_labs
- Download the latest firmware for your NUC
  - ⚠️ Warning: Asus has over taken over support for some NUC generations
    - https://www.asus.com/support/faq/1053028/
  - Extract the .BIO file from the Zip file you download
  - ⚠️ Beware that several NUC models may use the same .BIO file
- Unplug all USB sticks from NUC 1
- Plug in the USB that will be erased and used as the firmware upgrade USB stick
- Identify the USB stick device name
  - `lsblk`
  - Look for "sdb"
    - "sda" is usually your system drive, don't touch that one!
    - "sdb" will have the same size as your USB stick
- Format the USB stick - this example assumes it's "sdb"
  - Unmount partition that Ubuntu automatically mounted: `sudo umount /dev/sdb1`
  - Format it:  `sudo mkfs.vfat -I -F 32 -n 'FIRMWARE' /dev/sdb`
  - Confirm: `ls /dev/disk/by-label/`
- `mkdir /tmp/firmware`
- `sudo mount /dev/sdb /tmp/firmware`
- Copy the .BIO file to the USB stick
  - Example: `su cp BN0093.bio /tmp/firmware`
- Unmount the USB stick
  - `sudo umount /dev/sdb`
- You can now safely remove the USB stick
You can now use this USB stick to upgrade the firmware on NUCs that are compatible with the firmware.
