# Install FAH Client

References:
- https://foldingathome.org/faqs/installation-guides/linux/manual-installation-optional-advanced/terminal-installation-for-debian-mint-ubuntu/
- https://foldingathome.org/support/faq/installation-guides/linux/uninstall/
- https://foldingforum.org/viewtopic.php?f=108&t=36824

## Install Dependencies
`sudo apt install -y bzip2 dialog apt-utils python-apt`

## Download the installation package
`wget https://download.foldingathome.org/releases/public/release/fahclient/debian-testing-64bit/v7.4/fahclient_7.4.4_amd64.deb`

## Install the FAH Client
Install and configure the FAH client
- `sudo dpkg -i --force-depends fahclient_7.4.4_amd64.deb`
- Folding@home User Name: *enter name you want to use* or *Anonymous*
- Folding@home Team Number: *0* for no team, or enter a team number such as 1061684 for Team NUC
- If you have a Passkey, enter it. If not, continue without entering one.
- Resources: **full**
- Automatically started: **Yes**

⚠️ installed fahclient package post-installation script subprocess returned error exit status 1

## Remote Control

## Test

## Confirm Running After Reboot



## Learn More
### Uninstall FAH Application
This section describes how to uninstall V7 FAH application.
- Please let the current Work Unit finish and upload (using “Finish”)
- Open a terminal window. Enter the command appropriate for your version of Linux:
  - `sudo dpkg -P fahclient`
