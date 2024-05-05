# Install FAH Client
The official instructions generally work with with in important warning.
- https://foldingathome.org/faqs/installation-guides/linux/manual-installation-optional-advanced/terminal-installation-for-debian-mint-ubuntu/

⚠️ If you install Ubuntu Server with the minimalized package installation, the FAH client installation fails.
~~~~
/var/lib/dpkg/info/fahclient.postinst: line 40: /usr/share/doc/fahclient/sample-config.xml: No such file or directory
dpkg: error processing package fahclient (--install):
 installed fahclient package post-installation script subprocess returned error exit status 1
Errors were encountered while processing:
 fahclient
~~~~
Therefore do a normal (<ins>not minimal</ins>) installation of Ubuntu server. I have not been able to track down what package are missing/required.
- `dpkg-deb -I latest.deb` lists debconf
- debconf is included in the ubuntu minimal packages
- Here are some of the packages missing from "minimal"
~~~~
apt-utils
bash-completion
bc
bind9-dnsutils
bind9-host
bind9-libs:amd64
bolt
bsdextrautils
busybox-static
byobu
cloud-initramfs-copymods
cloud-initramfs-dyn-netconf
command-not-found
cron
debconf-i18n
distro-info
dmidecode
dosfstools
ed
eject
ethtool
file
fonts-ubuntu-console
friendly-recovery
ftp
fwupd
fwupd-signed
git
git-man
hdparm
htop
info
init
install-info
iptables
iputils-ping
iputils-tracepath
irqbalance
landscape-common
less
libarchive13:amd64
libatasmart4:amd64
libblockdev2:amd64
libblockdev-crypto2:amd64
libblockdev-fs2:amd64
libblockdev-loop2:amd64
libblockdev-part2:amd64
libblockdev-part-err2:amd64
libblockdev-swap2:amd64
libblockdev-utils2:amd64
liberror-perl
libestr0:amd64
libevent-core-2.1-7:amd64
libfastjson4:amd64
libflashrom1:amd64
libfribidi0:amd64
libftdi1-2:amd64
libfwupd2:amd64
libfwupdplugin5:amd64
libgcab-1.0-0:amd64
libgpgme11:amd64
libgpm2:amd64
libgusb2:amd64
libip6tc2:amd64
libjansson4:amd64
libjcat1:amd64
libjson-glib-1.0-0:amd64
libjson-glib-1.0-common
liblmdb0:amd64
libmagic1:amd64
libmagic-mgc
libmaxminddb0:amd64
libmbim-glib4:amd64
libmbim-proxy
libmm-glib0:amd64
libmspack0:amd64
libnetfilter-conntrack3:amd64
libnewt0.52:amd64
libnfnetlink0:amd64
libnftables1:amd64
libnftnl11:amd64
libnl-3-200:amd64
libnl-genl-3-200:amd64
libnspr4:amd64
libnss3:amd64
libnuma1:amd64
libparted2:amd64
libparted-fs-resize0:amd64
libpcap0.8:amd64
libpipeline1:amd64
libpython3.10:amd64
libqmi-glib5:amd64
libqmi-proxy
libslang2:amd64
libsmbios-c2
libsodium23:amd64
libtcl8.6:amd64
libtext-charwidth-perl
libtext-iconv-perl
libtext-wrapi18n-perl
libtss2-esys-3.0.2-0:amd64
libtss2-mu0:amd64
libtss2-sys1:amd64
libtss2-tcti-cmd0:amd64
libtss2-tcti-device0:amd64
libtss2-tcti-mssim0:amd64
libtss2-tcti-swtpm0:amd64
libudisks2-0:amd64
libutempter0:amd64
libuv1:amd64
libvolume-key1
libxmlsec1:amd64
libxmlsec1-openssl:amd64
libxslt1.1:amd64
locales
logrotate
lshw
lsof
lxd-agent-loader
man-db
manpages
modemmanager
motd-news-config
mtr-tiny
nano
netcat-openbsd
nftables
open-vm-tools
overlayroot
parted
pastebinit
patch
powermgmt-base
psmisc
python3-automat
python3-bcrypt
python3-commandnotfound
python3-constantly
python3-debian
python3-gdbm:amd64
python3-hamcrest
python3-hyperlink
python3-incremental
python3-magic
python3-newt:amd64
python3-openssl
python3-pexpect
python3-ptyprocess
python3-pyasn1
python3-pyasn1-modules
python3-service-identity
python3-twisted
python3-zope.interface
rsync
rsyslog
run-one
sbsigntool
screen
secureboot-db
sosreport
strace
tcl
tcl8.6
tcpdump
telnet
time
tmux
tnftp
tpm-udev
ubuntu-advantage-tools
ubuntu-minimal
ubuntu-pro-client-l10n
ubuntu-server
ubuntu-standard
udisks2
ufw
update-manager-core
update-notifier-common
usb.ids
usb-modeswitch
usb-modeswitch-data
uuid-runtime
vim
vim-common
vim-runtime
vim-tiny
whiptail
zerofree
~~~~
- spected packages
  - debconf-i18n
  - install-info
  - update-manager-core
References:
- https://foldingathome.org/faqs/installation-guides/linux/manual-installation-optional-advanced/terminal-installation-for-debian-mint-ubuntu/
- https://foldingathome.org/support/faq/installation-guides/linux/uninstall/
- https://foldingforum.org/viewtopic.php?f=108&t=36824
- https://foldingathome.org/support/faq/installation-guides/linux/command-line-options/

## Download the installation package
Download the package listed on the official guide or the latest package
- `wget https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/latest.deb`
- See https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/
- `wget https://download.foldingathome.org/releases/public/release/fahclient/debian-testing-64bit/v7.4/fahclient_7.4.4_amd64.deb`

## Install the FAH Client
Install and configure the FAH client
- Example commands:
  - `sudo dpkg -i --force-depends latest.deb`
  - `sudo dpkg -i --force-depends fahclient_7.4.4_amd64.deb`
- Folding@home User Name: *enter name you want to use* or *Anonymous*
- Folding@home Team Number: *0* for no team, or enter a team number such as 1061684 for Team NUC
- If you have a Passkey, enter it. If not, continue without entering one.
- Resources: **full**
- Automatically started: **Yes**
- Check the status
  - `sudo systemctl status FAHClient`

You will likely see this message.
~~~~
Failed to enable unit: Unit /run/systemd/generator.late/FAHClient.service is transient or generated.
~~~~

## Configure the Client
The FAH client configuration is stored at:
- ` /etc/fahclient/config.xml`

To update this file:
- Modify the file using sudo permissions
  - `sudo vi  /etc/fahclient/config.xml`
- Restart the client service
  - `sudo systemctl stop FAHClient`
  - `sudo systemctl start FAHClient`

You can view an example of a configuration file at [config.xml](config.xml)
- You will need to edit this file to put in your own Lab subnet CIDR (to replace 192.168.1.0/24) or just use the IP address of your workstation what will be running FAHControl
- I recommend you register for a passkey and put it in this file
  - https://foldingathome.org/support/faq/points/passkey/
  - Benefit #1 is you earn more points
- After updating the file, restart the service
  - `sudo systemctl stop FAHClient`
  - `sudo systemctl start FAHClient`
  - If you think the is a leftover process, reboot

## View Activity Locally
- You can view the log file
  - `tail /var/lib/fahclient/log.txt`
  - `sudo journalctl -u FAHClient`
- Find your packets-per-day score
  - `FAHClient --send-command ppd | grep ppd -A1`
- Look at your folding progress
  - `FAHClient --send-command queue-info`


## Confirm Running After Reboot
Feel free to reboot the system to confirm that FAH is automatically restarting after reboot.

## Controlling Folding Locally

- `FAHClient --send-pause` - pause folding
- `FAHClient --send-unpause` - unpause folding
- `FAHClient --send-finish` - finish all current work units, send the results, then exit.

## Remote Control
- Install the Folding at Home (FAH) software on a computer that has a GUI
  - https://foldingathome.org/support/faq/installation-guides/
- Open FAHControl
- To the left, there is a pane showing *Clients*
- In the bottom-right corder of this pane, click **Add**
  - Name: *assign any name you want*
  - Address: *the IP address of the NUC you configured*
  - Password: *the password you configured in `config.xml` file*
- You can now control the FAH client remotely
- If you have multiple systems folding, note the aggregate points per day estimate at the bottom

If you have having trouble connecting, check:
- config.xml - `<allow v='192.168.99.1/24'/>` has been updated to your Lab network or IP address
- config.xml - `<password v='supermassiveblackhole'/>` has been updated to the pasword you used

## Learn More
### Track Your Progress
Here are links to tracks your team's progress (using team NUC number as an example)
- https://stats.foldingathome.org/team/1061684
- https://folding.extremeoverclocking.com/team_summary.php?s=&t=1061684
  
### Working with the FAHClient service
Stop and start service
- `sudo systemctl stop FAHClient`
- `sudo systemctl start FAHClient`
Enable and disable service
- `sudo systemctl enable FAHClient`
- `sudo systemctl disable FAHClient
Logs
- journalctl -u FAHClient
