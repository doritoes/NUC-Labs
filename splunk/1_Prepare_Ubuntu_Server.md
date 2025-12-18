# Prepare Ubuntu Server
Requirements:
- CPU at least 2 to 4 vCPUs
- RAM: at least 4GB to 8GB
- 100GB is fine (Splunk compresses data at roughly a 50% ratio, so that space allows you to ingest hundreds of gigabytes of logs over time)

Install Ubuntu Server 24.04 LTS on the NUC or VM you are using to run Splunk. For this Lab I am running it as a VM on a NUC running XCP-ng.
- Defaults for just about everything
- At **Storage Configuration** edit the ubuntu-lv mounted as root (/) to be the maximum size (i.e., 96.945G)
- Credentials
  - Your name: `splunk`
  - Your servers name: `splunk`
  - Pick a username: `lab`
  - Choose a password: `Splunklab123!`
- Enable **Install OpenSSH server**
- Don't install any snaps

## Package Updates
Do the usual packages updates
- Log in as `lab`/`Splunklab123!`
- `ip a`
  - Find the IP address so you can ssh to the server remotely if you wish
- `sudo apt update && sudo apt -y upgrade && sudo apt autoremove -y`


## System Tuning
Run these steps before you install the Splunk .deb package to avoid the "Yellow Warning" banners in the Splunk UI. Reboot after the changes are complete.

### Disable Transparent Huge Pages (THP)
THP is a Linux memory management feature that causes significant performance "stuttering" for database-like apps like Splunk.

1. Create a systemd service to disable it on every boot
  - `sudo vi /etc/systemd/system/disable-thp.service`
  - Paste in the contents of disable-thp.service ([disable-thp.service](disable-thp.service))
2. Enable and start it: `sudo systemctl daemon-reload && sudo systemctl enable --now disable-thp.service`

### Increase "ulimits" (Open File Limits)
Splunk keeps many "buckets" (files) open at once. The default Ubuntu limit (1024) is way too low.

1. Edit the limits file: `sudo vi /etc/security/limits.conf`
  - Add these lines to the very bottom:
    - `* soft nofile 65535`
    - `* hard nofile 65535`
    - `* soft nproc 20480`
    - `* hard nproc 20480`
  - NOTE: The * applies to all users. If you create a specific splunk user later, you can replace the * with splunk.
