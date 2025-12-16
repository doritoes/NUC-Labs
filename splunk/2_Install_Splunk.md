# Install Splunk
NOTE At the time of writing, the current version is Splunk Enterprise 10.0.2.

Pro Tip: The Dockerd Shortcut
- there is a secret version: The Splunk Enterprise for Docker image often comes pre-licensed with a 20GB/day trial that is very robust
- See Appendix - Splunk Docker ([Appendix_Splunk_Docker.md](Appendix_Splunk_Docker.md))

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
5. Paste this link (really a command) into the server:
  - Simlar to: `wget -O splunk-10.0.2-e2d18b4767e9-linux-amd64.deb "https://download.splunk.com/products/splunk/releases/10.0.2/linux/splunk-10.0.2-xxxx-linux-amd64.deb"`
  - NOTE the file is over 1.2GB

## Install Splunk
1. Run this commmpand on the server, adjusting for your file name: `sudo dpkg -i splunk-10.0.2-xxxx-linux-amd64.deb`
2. First Run: sudo /opt/splunk/bin/splunk start --accept-license
  - It will ask you to create an admin username and password
  - Do not lose these; they are for the web UI (splunkadmin/splunkadmin is fine for this lab)
3. Post-Installation: Best Practices
  - Enable Boot Start: To ensure Splunk starts when your VM reboots: `sudo /opt/splunk/bin/splunk enable boot-start`
  - Open Firewall Ports: Ubuntu 24.04 usually has ufw disabled by default, but if you enabled it, you must open the Web UI and the indexing port:
    - `bash`
    - `sudo ufw allow 8000/tcp`   # Web UI
    - `sudo ufw allow 9997/tcp`   # Data from Forwarders
    -  `sudo ufw allow 8089/tcp`   # Management Port

## Test
1. http://<ipaddress>:8000
2. Log in with the account you configured

NOTE this is NOT secure!

## Enable HTTPS
Modify to your selected username and password
1. `sudo /opt/splunk/bin/splunk enable web-ssl -auth <username>:<password>`
2. `sudo /opt/splunk/bin/splunk restart`
3. https://<ipaddress>:8000

Accept the self-signed certificate and log back in.

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
