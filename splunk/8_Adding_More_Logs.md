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
  - In web UI Apps > Manage Apps
  - Install app from file
  - Upload the TA-pfsense.tgz you just created
- Settings > Data > Data Inputs > UDP > **Add new**
  - Port: 1514
  - Source name override: *leave blank*
  - Next
  - Select Source Type: pfsense
  - App Context: Search & Reporting
  - Host: IP (perfect for this Lab)
  - Index: main (in production, use pfsense)
  - Review > Submit

### On the Firewall
- On some systems it might be at System > Logging > Remote
- In my lab Status > Syste Logs > Settings
- Under **Remote Logging Options**
  - Enable (check) **Send log messages to remote syslog server**
    - Source Address: Default (any)
    - IP Protocol: IPv4
    - Remote log servers: your IP address with port 1514 after it
      - ex., 192.168.100.50:1514
    - Remote Syslog Contents
      - Firewall Events
      - DHCP Events
      - add additonal log types as you wish

### Search
Unfortunately my test pfSense logs aren't fully parsing yet. My version is 2.7.2
- `index="main" sourcetype="pfsense"`

Trying the fix
- `sudo mkdir -p /opt/splunk/etc/apps/TA-pfsense/local/`
- `sudo vi /opt/splunk/etc/apps/TA-pfsense/local/inputs.conf`
~~~
[udp://1514]
index = main
sourcetype = pfsense
connection_host = ip
no_appending_timestamp = true
~~~
- sudo /opt/splunk/bin/splunk restart

No success yet.

Plugin uses 5016. try that next?

## OPNsense
Set up TCP syslog to Splunk.
- Pros: Easy to set up; no extra software on the firewall.
- Cons: UDP is "fire and forget" (logs can be dropped during network congestion); standard syslog isn't encrypted.
### On the firewall
- Settings > Logging > Remote
- Enable remote logging and point it to your Splunk IP on port 514 (standard syslog) or a high port like 1514
### On Splunk
- Settings > Data Inputs > UDP/TCP and create a listener on that same port.
- Intall the OPNsense plug-in - https://splunkbase.splunk.com/app/4538

## Synology
Set up TCP syslog to Splunk.
- Pros: Easy to set up; no extra software on the firewall.
- Cons: UDP is "fire and forget" (logs can be dropped during network congestion); standard syslog isn't encrypted.

NOTE NAS devices can support a lot of different application. Here are a couple use cases.
- detect brute-force attempts to the managment interface or SMB shares
- detect renames or modifying of bulk amount of files (ransomewar)

### On the NAS box
- ? set up remote logging
### On Splunk
- Settings > Data Inputs > UDP/TCP and create a listener on that same port.
- Install the Synology plug-on - https://splunkbase.splunk.com/app/7316









3. The Specialized Method: Splunk Add-on for pfSense/OPNsense
To actually understand the logs (parsing the firewall rules, NAT translations, and DHCP leases), you need an Add-on to perform CIM (Common Information Model) mapping.

Recommendation: Use the Splunk Add-on for pfSense (works similarly for OPNsense).

What it does: It takes the "wall of text" from the syslog and breaks it into fields like src_ip, dest_port, and action.




NAS
https://splunkbase.splunk.com/app/7316
