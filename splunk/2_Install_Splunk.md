# Install Splunk
NOTE At the time of writing, the current version is Splunk Enterprise 10.0.2.

## Create a Splunk Account
This is somewhat awkward for a homelab user. IT requests your "business email" address, company name, and job title. It didn't immediatelly choke when I submitted a @gmail address and "Personal" as the company name.
1. https://splunk.com
2. Login > Sign Up
3. Click the activation link that is emailed to you

## Donwload the Splunk Package
1. After logging in, click **Trials & Downloads**
2. Under Splunk Enterprise, click **Start Trial**
3. Click on the Linux tab
4. Next to the **.deb** version click **Copy wget link**
  - this is a personal link with a token that expires
5. Paste this link into the server:
  - Simlar to: `wget -O splunk-10.0.2-e2d18b4767e9-linux-amd64.deb "https://download.splunk.com/products/splunk/releases/10.0.2/linux/splunk-10.0.2-e2d18b4767e9-linux-amd64.deb"`

## Install Splunk
1. Run this commmpand on the server, adjusting for your file name: `sudo dpkg -i splunk-10.0.2-xxxx-linux-amd64.deb`
2. First Run: sudo /opt/splunk/bin/splunk start --accept-license
  - It will ask you to create an admin username and password
  - Do not lose these; they are for the web UI
3. Post-Installation: Best Practices
  - Enable Boot Start: To ensure Splunk starts when your VM reboots: `sudo /opt/splunk/bin/splunk enable boot-start`
  - Open Firewall Ports: Ubuntu 24.04 usually has ufw disabled by default, but if you enabled it, you must open the Web UI and the indexing port:
    - `bash`
    - `sudo ufw allow 8000/tcp`   # Web UI
    - `sudo ufw allow 9997/tcp`   # Data from Forwarders
    -  `sudo ufw allow 8089/tcp`   # Management Port

## Test
1. http://<ipaddress>:8000

## Developer License
Comparison:
- Free license: 500MB/day ingest, perpetual, no alerting, no user login (auto-login as admin), limited apps, single instance only
- Enterprise Trial: 500MB/day ingest, 60 days, alerting, user login, all apps including ES trial, single instance only
- Developer Personal license: 10GB/day, 6 months (renewable), alerting, user login, all apps, single or distributed

NOTE Personal license is not an instant download; it requires a quick "application" (usually approved in 1–3 days):
1. Go to dev.splunk.com
2. Click Join
3. Log in using your Splunk account
4. Register and fill out the questionnaire, accepts the T&C, privacy policy, click **Submit**
5. Click "Request Developer License
  - `Your request is under review. Expect an email in 3–5 business days.`
6. They will email you an .xml file
7. In your Ubuntu Splunk Web (Port 8000), go to Settings > Licensing > Add License and upload that file


Great choice on the local VM—100GB on an SSD is perfect for a learning lab. Splunk compresses data at roughly a 50% ratio, so that space allows you to ingest hundreds of gigabytes of logs over time before you even have to think about "retention policies."

Ubuntu 24.04 is a solid host, but it’s "too efficient" out of the box for Splunk. You need to "loosen" the OS restrictions so Splunk can handle thousands of small log files simultaneously.

1. Pre-Installation: System Tuning
Run these steps before you install the Splunk .deb package to avoid the "Yellow Warning" banners in the Splunk UI.

A. Disable Transparent Huge Pages (THP)
THP is a Linux memory management feature that causes significant performance "stuttering" for database-like apps like Splunk.

Create a systemd service to disable it on every boot: sudo nano /etc/systemd/system/disable-thp.service

Paste this in:

Ini, TOML

[Unit]
Description=Disable Transparent Huge Pages (THP)
[Service]
Type=oneshot
ExecStart=/bin/bash -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"
[Install]
WantedBy=multi-user.target
Enable and start it: sudo systemctl daemon-reload && sudo systemctl enable --now disable-thp.service

B. Increase "ulimits" (Open File Limits)
Splunk keeps many "buckets" (files) open at once. The default Ubuntu limit (1024) is way too low.

Edit the limits file: sudo nano /etc/security/limits.conf

Add these lines to the very bottom:

Plaintext

* soft nofile 65535
* hard nofile 65535
* soft nproc 20480
* hard nproc 20480
(Note: The * applies to all users. If you create a specific splunk user later, you can replace the * with splunk.)

2. The Installation Process
Since you have a clean Ubuntu 24.04 server, avoid using snap. Use the official .deb from Splunk.com.

Download: Go to Splunk.com, log in, and grab the Linux .deb link (use the "Download via Command Line" wget option).

Install: sudo dpkg -i splunk-9.x.x-xxxx-linux-2.6-amd64.deb

First Run: sudo /opt/splunk/bin/splunk start --accept-license

It will ask you to create an admin username and password. Do not lose these; they are for the web UI.

3. Post-Installation: Best Practices
Enable Boot Start: To ensure Splunk starts when your VM reboots: sudo /opt/splunk/bin/splunk enable boot-start

Open Firewall Ports: Ubuntu 24.04 usually has ufw disabled by default, but if you enabled it, you must open the Web UI and the indexing port:

Bash

sudo ufw allow 8000/tcp   # Web UI
sudo ufw allow 9997/tcp   # Data from Forwarders
sudo ufw allow 8089/tcp   # Management Port
The "Developer License": As mentioned, log into dev.splunk.com and grab your 10GB/day license file. Upload it in the Splunk UI under Settings > Licensing.


Free license: 500MB/day ingest, perpetual, no alerting, no user login (auto-login as admin), limited apps, single instance only

Enterprise Trial: 500MB/day ingest, 60 days, alerting, user login, all apps including ES trial, single instance only

Personal license: 10GB/day, 6 months (renewable), alerting, user login, all apps, single or distributed


Personal license is not an instant download; it requires a quick "application" (usually approved in 1–3 days):

Go to dev.splunk.com.

Sign up for the Splunk Developer Program (free).

Click "Request Developer License."

They will email you an .xml file.

In your Ubuntu Splunk Web (Port 8000), go to Settings > Licensing > Add License and upload that file.

Pro-Tip: The "Docker" Shortcut
If you find the license application takes too long, there is a "secret" version: The Splunk Enterprise for Docker image often comes pre-licensed with a 20GB/day trial that is very robust. However, since you already have your Ubuntu VM ready, the .deb install with the Developer License is the most "production-realistic" way to learn.

Appendix_Splunk_Docker.md
