# Adding More Logs

## Using the Univeral Forwarder
Splunk has an "agent" called the Universal Forwarder (UF) that will harvest local logs and forward them to the Splunk indexer running on the server.

### Configure the Splunk Listener
1. Open port 9997
    - Log into Splunk Web UI
    - **Settings** > **Forwarding and Receiving**
    - Click **Configure receiving** under "Receive data"
    - Click **New Receiving Port**
        - Enter: **9997** and click **Save**
2. If your server has the software firewall (UFW) enabled, allow the port
    - `sudo ufw status`
    - `sudo ufw allow 9997/tcp`
### Install UF
#### Windows 11
1. Download the Windows 64-bit MSI file
    - https://splunk.com/en_us/download/universal-forwarder.html
    - You need to log in
    - Windows tab > 64-bit > Download Now
    - Accept the terms
2. Launch the installer named similar to `splunkforwarder-10.0.2-xxxxxx-windows-x64`
    - Accecpt the agreement
    - Use this UniversalForwarder with: **An on-premises Splunk Enterprise instance**
    - Click **Next**
    - Create Credentials
        - Create a local admin for the UF (e.g., admin / YourPassword)
        - NOTE This is just for local CLI access on the Windows box
        - Leave **Generate random password** check and click **Next**
    - Deployment Server:
        - Leave this blank and click **Next**
        - NOTE This is for managing 1,000s of forwarders; we don't need it yet
    - Receiving Indexer (Crucial):
        - Hostname or IP: **the IP address of your Ubuntu Server running splunk**)
            - NOTE if you are running DHCP in your Lab, I recommend you set up a DHCP reservation so the IP address doesn't change
        - Port: leave empty, defualt is 9997
        - Click **Next**
    - Click **Install** and then click **Finish**


Select Logs to Collect: The installer will show a list. Check:
- Application
- Security
- System
Finish & Install.




OPNsense

pfSense

NAS
