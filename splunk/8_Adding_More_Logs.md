# Adding More Logs

advanced use of the Universal Forwarder

other methods besides the Universal Forwarder

OPNsense
https://community.splunk.com/t5/c-oqeym24965/OPNsense+Add-on+for+Splunk/pd-p/4538


pfSense
https://splunkbase.splunk.com/app/5613


. The Standard Method: Remote Syslog (UDP/TCP)
This is the "agentless" approach. You configure the firewall to push logs directly to Splunk.

or install on the firewall, it's BSD, set inputs.conf and outputs.conf

How to do it:

On the Firewall: Go to System > Logging > Remote (pfSense) or Settings > Logging > Remote (OPNsense). Enable remote logging and point it to your Splunk IP on port 514 (standard syslog) or a high port like 1514.

On Splunk: Go to Settings > Data Inputs > UDP/TCP and create a listener on that same port.

Pros: Easy to set up; no extra software on the firewall.

Cons: UDP is "fire and forget" (logs can be dropped during network congestion); standard syslog isn't encrypted.




3. The Specialized Method: Splunk Add-on for pfSense/OPNsense
To actually understand the logs (parsing the firewall rules, NAT translations, and DHCP leases), you need an Add-on to perform CIM (Common Information Model) mapping.

Recommendation: Use the Splunk Add-on for pfSense (works similarly for OPNsense).

What it does: It takes the "wall of text" from the syslog and breaks it into fields like src_ip, dest_port, and action.




NAS
https://splunkbase.splunk.com/app/7316
