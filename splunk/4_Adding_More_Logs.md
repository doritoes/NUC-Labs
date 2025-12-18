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

### Install the Splunk Add-On for Microsoft Windows
1. Log in to Splunk web UI
2. Go to the home screen
3. Left-hand sidebar, click **Find more apps**
4. Search for "Splunk Add-on for Microsoft Windows"
5. Click **Install**
6. Enter your <ins>splunk.com</ins> username and password and click **Agree and Install**
7. Restart Splunk
    - **Settings** > **Server Controls** > **Restart Splunk**
    - or command line `sudo /opt/splunk/bin/splunk restart`
### Install UF
#### Windows 11
Set up a Windows 11 test machine and install Google Chrome on it.

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
3. Configure what logs to collect
    - Since we used the default settings, we need to tell UF what logs to collect
    - If we had used** Customize** option we would have selected
        - Application
        - Security
        - System
    - Open **Notepad** as an **Administrator**
        - Paste in the contents of inputs.conf [inputs.conf](inputs.conf)
        - Click **File** > **Save as**
        - Navigate to `C:\Program Files\SplunkUniversalForwarder\etc\system\local\`
        - Name the file **inputs.conf** and **Save** it
        - Since Windows 11 Notepad doesn't like to name things correctly, it might add the .txt extension. Rename to just "inputs.conf"
    - UF only reads this file when it starts up
      - Open administrative PowerShell
      - `Restart-Service SplunkForwarder`
3. Confirming logs arrive
    - Log in to the Splunk Web UI
    - `| metadata type=hosts`
      - If your Windows host name shows up, it is working!
    - `index=_internal host=<WINDOWS_HOSTNAME_HERE>` (usually all lowercase in Splunk)
    - `index=main sourcetype="WinEventLog:Security"`
4. Test "Insider Threat" Scenario
    - Local Console
        - Lock the screen and attempt to log in with a wrong password 3 or 4 times
            - NOTE Logging in with a PIN doesn't populate the TargetUserName field(!) It will show the Sub_status 0xc0000380 STATUS_SMARTCARD_SILENT_CONTEXT
        - Log in with the correct password
        - Open the Splunk search bar
        - Set the Time Picker to "Last 15 minutes"
        - Run the following search to find the failures:
            - `index=main sourcetype="WinEventLog:Security" EventCode=4625`
        - Note the **Interesting Fields** on the left
          - Account_Name: The account they tried to hack
          - Logon_Type: 2 (Interactive) or 7 (Unlock)
          - IpAddress: empty, missing or 127.0.0.1 for console login
          - Status: The hex code for why it failed (e.g., 0xc000006d means bad password)
          - Sub_status: 0xC000006A (STATUS_WRONG_PASSWORD)
    - RDP to Win 11 computer
        - Try wrong password 3 or 4 times
        - Log in with the correct password
        - Open the Splunk search bar
        - Set the Time Picker to "Last 15 minutes"
        - Run the following search to find the failures:
            - `index=main sourcetype="WinEventLog:Security" EventCode=4625`
        - Note the **Interesting Fields** on the left
          - Account_Name: The account they tried to hack
          - Logon_Type: 3 (Network Login) mean NLA negotiated credentials before RDP fully opened; Type 10 is what we classically expected for RDP
          - Source_Network_Address: the IP address you tried to log in <ins>from</ins>
          - Status: The hex code for why it failed (e.g., 0xc000006d means bad password)
          - Sub_status: 0xC000006A (STATUS_WRONG_PASSWORD)
      - Use a "friendly" query that uses the Windows Plugin
```
index=main EventCode=4625 
| table _time, user, src_ip, Logon_Type, status
```

5. Test "Persistence" Scenario (New User Account)
    - On the Windows 11 maching open an administrative command prompt
    - Create a new user: `net user LabVictim Splunk123! /add"
    - In Splunk search bar
        - query: `index=main sourcetype="WinEventLog:Security" EventCode=4720`
    - Identify the name of the user that was created and the user that created them



OPNsense

pfSense

NAS
