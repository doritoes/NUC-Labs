# Install FAH Client
The official instructions error out in the Lab:
- https://foldingathome.org/faqs/installation-guides/linux/manual-installation-optional-advanced/terminal-installation-for-debian-mint-ubuntu/`
- same sypt

References:
- https://foldingathome.org/faqs/installation-guides/linux/manual-installation-optional-advanced/terminal-installation-for-debian-mint-ubuntu/
- https://foldingathome.org/support/faq/installation-guides/linux/uninstall/
- https://foldingforum.org/viewtopic.php?f=108&t=36824

## Install Dependencies
`sudo apt install -y bzip2 dialog apt-utils python3-apt`

## Download the installation package
All of these packages are failing
- `wget https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/latest.deb`
- `wget https://download.foldingathome.org/releases/public/release/fahclient/debian-testing-64bit/v7.4/fahclient_7.4.4_amd64.deb`

## Install the FAH Client
Install and configure the FAH client
- Tried commands
  - `sudo dpkg -i --force-depends fahclient_7.4.4_amd64.deb`
  - `sudo dpkg -i --force-depends latest.deb`
- Folding@home User Name: *enter name you want to use* or *Anonymous*
- Folding@home Team Number: *0* for no team, or enter a team number such as 1061684 for Team NUC
- If you have a Passkey, enter it. If not, continue without entering one.
- Resources: **full**
- Automatically started: **Yes**

⚠️ installed fahclient package post-installation script subprocess returned error exit status 1
~~~~
/var/lib/dpkg/info/fahclient.postinst: line 40: /usr/share/doc/fahclient/sample-config.xml: No such file or directory
dpkg: error processing package fahclient (--install):
 installed fahclient package post-installation script subprocess returned error exit status 1
Errors were encountered while processing:
 fahclient
~~~~

## Remote Control
🚧To be continued...

## Test
🚧To be continued...

## Confirm Running After Reboot
🚧To be continued...


## Learn More
### Uninstall FAH Application
This section describes how to uninstall V7 FAH application.
- Please let the current Work Unit finish and upload (using “Finish”)
- Open a terminal window. Enter the command appropriate for your version of Linux:
  - `sudo dpkg -P fahclient`
