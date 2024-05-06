# Install FAH Client
The official instructions generally work, with an important warning.
- https://foldingathome.org/faqs/installation-guides/linux/manual-installation-optional-advanced/terminal-installation-for-debian-mint-ubuntu/

⚠️ If you install Ubuntu Server with the minimalized package installation, the FAH client installation fails.
~~~~
/var/lib/dpkg/info/fahclient.postinst: line 40: /usr/share/doc/fahclient/sample-config.xml: No such file or directory
dpkg: error processing package fahclient (--install):
 installed fahclient package post-installation script subprocess returned error exit status 1
Errors were encountered while processing:
 fahclient
~~~~
Therefore do a normal (<ins>not minimal</ins>) installation of Ubuntu server. I unsucessfuly tried to find any missing dependencies.
- `dpkg-deb -I latest.deb` lists debconf, but debconf is included in the ubuntu minimal packages
- I installed the 187 packages that were missing in "minimal", and the install still failed.

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
- `sudo systemctl disable FAHClient`
Logs
- `journalctl -u FAHClient`
