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

I recommend you register for a passkey
- https://foldingathome.org/support/faq/points/passkey/
- Benefit #1 is you earn more points
- Edit the config.xml file and restart FAHClient

## Remote Control
🚧To be continued...

## Test
https://foldingathome.org/support/faq/installation-guides/linux/command-line-options/

🚧To be continued...

## Confirm Running After Reboot
🚧To be continued...


## Learn More
### Working with the FAHClient service
Stop and start service
- `sudo systemctl stop FAHClient`
- `sudo systemctl start FAHClient`
Enable and disable service
- `sudo systemctl enable FAHClient`
- `sudo systemctl disable FAHClient
Logs
- journalctl -u FAHClient

### Uninstall FAH Application
This section describes how to uninstall V7 FAH application.
- Please let the current Work Unit finish and upload (using “Finish”)
- Open a terminal window. Enter the command appropriate for your version of Linux:
  - `sudo dpkg -P fahclient`
