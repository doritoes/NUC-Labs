# Create USB Sticks
Create the modified ISO for USB installation of remaining NUCs. These steps are performed while logged in to NUC1.

💡 You can open these instructions from NUC1 for your convenience.

# Download Server ISO
- Download the latest <ins>live-server</ins> ISO from the [Ubuntu 22.04 releases page](https://releases.ubuntu.com/22.04/)
  - Named similar to ubuntu-22.04.4-live-server-amd64.iso
- Move the ISO file to your home directory (e.g. /home/ubuntu/)

# Install livefs-editor
- Open the terminal (should be in your home directory by default)
- Install livefs-editor, which will be used to modify the ISO
~~~~
git clone https://github.com/mwhudson/livefs-editor
cd livefs-editor
sudo python3 -m pip install .
~~~~
- Return to your home directory (`cd ~` or `cd ..`)
# Create modified live-server ISO
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
livefs-edit $ORIG_ISO $MODDED_ISO --cp /tmp/grub.cfg new/iso/boot/grub/grub.cfg
~~~~
# Create bootable USB stick from the modified ISO
Use [Balena Etcher](https://www.balena.io/etcher) or [Startup Disk Creator](https://ubuntu.com/tutorials/create-a-usb-stick-on-ubuntu#1-overview)

## BalenaEtcher
- Download Etcher for Linux x64 (64-bit) (AppImage)
- In a terminal, assign executable permissions to the downloaded file
  - For example, if the file is named `balenaEtcher-1.18.11-x64.AppImage`
  - Type `sudo chmod +x Downloads/balenaEtcher-1.18.11-x64.AppImage`
- Extract the app image
- `sudo chmod +x Downloads/balenaEtcher-1.18.11-x64.AppImage--appimage-extract`


# Create the CIDATA USB stick
# Create the firmware upgrade USB stick
# Create SSH management keys

🚧 continue working here
