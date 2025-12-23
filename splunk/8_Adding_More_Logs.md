# Adding More Logs
You can add more log sources to Splunk. Firewalls and NAS devices are really useful. For the devices that run BSD like pfSense and OPNsense it's possible to install UF to collect the logs.

In the majority of cases you will use the "agentless" approach to configure the device to send syslog (UDP/TCP) directly to Splunk. For production configurations using a Splunk Heavy Forwarder (HF). It's full Splunk Enterprise instance dedicated to collect, parse, filter, and route machine data. It reduces the load on indexers, stores data locally before sending it.

In this lab we will send directly to the Splunk server, which is our head-end and indexer. Options include configuring a Syslog-NG service on the Splunk server to injest from, or syslogging directly to Splunk. We will log directly to Splunk.

IMPORTANT Sending logs to Splunk isn't useful without a Splunk plug-in to parse the logs to match the common information model (CIM). To actually understand the logs (parsing the firewall rules, NAT translations, and DHCP leases), you need an Add-on to perform CIM (Common Information Model) mapping.

Firewalls:
- OPNsense - https://splunkbase.splunk.com/app/4538
- pfSense - https://splunkbase.splunk.com/app/5613
- Unifi - https://splunkbase.splunk.com/app/7494
NAS:
- Synology - https://splunkbase.splunk.com/app/7316


## pfSense
Set up UDP syslog to Splunk. I prefer TCP but my version only uses TDP.
- Pros: Easy to set up; no extra software on the firewall.
- Cons: UDP is "fire and forget" (logs can be dropped during network congestion); standard syslog isn't encrypted.

### On Splunk
- Intall the pfSense plug-in - https://splunkbase.splunk.com/app/5613
  - Log in, follow link to https://github.com/barakat-abweh/ta-pfsense
  - git clone https://github.com/barakat-abweh/ta-pfsense.git
  - mv ta-pfsense TA-pfsense
  - tar -cvzf TA-pfsense.tgz TA-pfsense/
  - In web UI **Apps** > **Manage Apps**
  - **Install app from file**
  - Upload the **TA-pfsense.tgz** file you just created
- `sudo cp /opt/splunk/etc/apps/TA-pfsense/default/inputs.conf /opt/splunk/etc/apps/TA-pfsense/local/inputs.conf`
- `sudo chmod 644 /opt/splunk/etc/apps/TA-pfsense/local/inputs.conf`
- `sudo vi /opt/splunk/etc/apps/TA-pfsense/local/inputs.conf`
  - Modify index from `pfsense` to `main`
  - Modify connection_host from `dns` to `ip`
  - Modify disabled from `1` to `0`
- `sudo /opt/splunk/bin/splunk restart`

### On the Firewall
- On some systems it might be at System > Logging > Remote
- In my lab **Status** > **System Logs** > **Settings**
- Under **General Logging Options**
  - Note the log message format defaults to BSD (RFC3164, default)
  - The plug-in requires pfSense to send data in **syslog** (RFC 5424) format
- Under **Remote Logging Options**
  - Enable (check) **Send log messages to remote syslog server**
    - Source Address: Default (any)
    - IP Protocol: IPv4
    - Remote log servers: your IP address with port 5016 after it
      - ex., 192.168.100.50:5016
    - Remote Syslog Contents
      - Firewall Events
      - DHCP Events
      - add additonal log types as you wish

### Search
Unfortunately my test pfSense logs aren't fully parsing yet. My version is 2.7.2
- `index="main" sourcetype="pfsense"`

No success yet.

## Synology
Set up TCP syslog to Splunk.
- Pros: Easy to set up; no extra software on the firewall.
- Cons: UDP is "fire and forget" (logs can be dropped during network congestion); standard syslog isn't encrypted.

NOTE NAS devices can support a lot of different application. Here are a couple use cases.
- detect brute-force attempts to the managment interface or SMB shares
- detect renames or modifying of bulk amount of files (ransomewar)

### On Splunk
- Install the Synology plug-on - https://splunkbase.splunk.com/app/7316
  - Download the .tgz file
  - In Splunk Apps > Manage > Install App From File
- Settings > Data Inputs > UDP/TCP and create a listener on TCP 1514
  - Select Source Type: synology:nas:syslog
  - Method: IP
  - Index: main
  - Click **Review** then **Submit**

### On the NAS box
- Open Log Center > - Log Sending
- **Enable** (check) Send logs to a syslog server
- Server: IP address of the Splunk server
- Port: **1514**
- Transfer protocol: **TCP**
- Log format: **IETF (RFC 5424)**
- Click Apply

### Search
- `source="tcp:1514" index="main" sourcetype="synology:nas:syslog"`

## OPNsense
Set up TCP syslog to Splunk.
- Pros: Easy to set up; no extra software on the firewall.
- Cons: UDP is "fire and forget" (logs can be dropped during network congestion); standard syslog isn't encrypted.

### On Splunk
- Install the OPNsense plug-in - https://splunkbase.splunk.com/app/4538
- Settings > Data Inputs > UDP/TCP and create a listener on port.... 1515?????

### On the firewall
- Settings > Logging > Remote
- Enable remote logging and point it to your Splunk IP on port 514 (standard syslog) or a high port like 1515???


### Search

