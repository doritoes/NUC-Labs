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
    - TODO If it if you want to use system account or the virtual splunk forwarder (more secure), use local system account because we will be using sysmon
    - TODO if this doesn't show up, we have to open Services and change LogOnAs to local system account
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
4. Confirming logs arrive
    - Log in to the Splunk Web UI
    - `| metadata type=hosts`
      - If your Windows host name shows up, it is working!
    - `index=_internal host=<WINDOWS_HOSTNAME_HERE>` (usually all lowercase in Splunk)
    - `index=main sourcetype="WinEventLog:Security"`
5. Test "Insider Threat" Scenario
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

6. Confirm Successful Logins
```
index=main EventCode=4624
| table _time, user, src_ip, Logon_Type
```

NOTE You will see the service accounts like DWM-4 (Desktop Window Manager) and UMDF-4 (User Mode Driver Framework) logging in. Look up what these are used for. It's a fun read.

7. Test "Persistence" Scenario (New User Account)
    - On the Windows 11 maching open an administrative command prompt
    - Create a new user: `net user LabVictim Splunk123! /add"
    - In Splunk search bar
        - query: `index=main sourcetype="WinEventLog:Security" EventCode=4720`
    - Identify the name of the user that was created and the user that created them
8. Test "Wiping the Evidence" Scenario (Log Clearing)
    - This is a Priority 1 alert in any real-world SOC
    - On Windows 11 machine open and administrative command prompt
    - Run the command: `wevtutil cl Security`
    - This clears the Security log (!)
    - Detect it in Splunk search
```
index=main EventCode=1102
| table _time, user, host, msg
```
9. Test "PowerShell Execution" Scenario (Living off the Land)
    - Most modern attacks don't use .exe files anymore, they use PowerShell to run commands directly in memory
    - On Windows 11 machine: **Start** > **gpedit.msc**
        - Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > System Audit Policies > Detailed Tracking
        - In right-hand page double click **Audit Process Creation**
        - Check both **Succcess** and **Failure**
        - Click **Apply** then **OK**
    - **Start** > **gpedit.msc**
        - Computer Configuration > Administrative Templates > System > Audit Process Creation
        - Double click **Include command line in process creation events**
        - Select **Enabled**
        - Click **Apply** then **OK**
- **Start** > **gpedit.msc**
        - Computer Configuration > Administrative Templates > Windows Components > Windows PowerShell
        - Double click **Turn On PowerShell Script Block Logging**
        - Select **Enabled** (don't check "Log invocation start/stop", very verbose)
        - Click **Apply** then **OK**
    - From command prompt: **gpupdate /force**
    - Open PowerShell
    - Run: notepad.exe "C:\splunk_test.txt"
    - Run: `Write-Host "Simulating Malware Download" -ForegroundColor Red`
    - Run: `Get-Service | Where-Object {$_.Status -eq "Stopped"}`
    - Detect it in Splunk search
~~~
index=main EventCode=4688 process_name!="splunk-powershell.exe"
| search "powershell.exe"
| table _time, user, process_name, New_Process_Name, CommandLine
~~~

~~~
index=main EventCode=4104
~~~

~~~
index=main EventCode=4104
| xmlkv
| table _time, ScriptBlockText
~~~

10. Track browser launch and any funny command line arguments
~~~
index=main EventCode=4688 (process_name="chrome.exe" OR process_name="msedge.exe")
| table _time, user, process_name, CommandLine
~~~

11. Installing Sysmon
    - Download Sysmon to the Windows 11 machine: https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon
    - Extract the .zip file to C:\Tools or similar
    - Download the config **sysmonconfig-export.xml** from the [SwiftOnSecurity GitHub](https://github.com/SwiftOnSecurity/sysmon-config)
    - Place the config .xml in the same folder (e.g., C:\Tools)
    - Open administrative powershell
    - Navigate to your folder (e.g., C:\Tools)
    - Run: `.\Sysmon64.exe -i sysmonconfig-export.xml -accepteula`
        - Installs Sysmon as a service
        - Uses the SwiftOnSecurity settings to folder out "normal" Windows noise
    - Confirm/Add to the `inputs.conf` file:
        - [WinEventLog://Microsoft-Windows-Sysmon/Operational]
        - disabled = 0
        - index = main
        - renderXml = 1
        - sourcetype = XmlWinEventLog:Microsoft-Windows-Sysmon/Operational
    - If you changed anything,restart the forwarder
        - `Restart-Service SplunkForwarder`

12. The "Kill Chain" Lab: Track the Chrome (or Edge) download (Event ID 11)
    - Login to the Windows 11 machine
    - Download the installer for 7-Zip (any file will do)
    - Search in Splunk:
~~~
index=main EventCode=11
| xmlkv
| table _time, Image, TargetFilename
~~~

    - Image: The process that created the file (e.g., chrome.exe or msedge.exe)
    - TargetFilehame: Exactly where it landed on the disk
    - NOTE With additional configuration on the UF, the PowerShell and Sysmon logs will be properly parsed from the XML. It involves dropping your preconfigured folder with `inputs.conf` into `etc/apps/`. Then you should be able to run the query:
~~~
index=main sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=11
| xmlkv
| table _time, Image, TargetFilename
~~~

    - Download an exe (Event ID 11)
~~~
# Simulate a download of the 7-Zip installer
$url = "https://www.7-zip.org/a/7z2301-x64.exe"
$dest = "$env:USERPROFILE\Downloads\7z_installer.exe"
Invoke-WebRequest -Uri $url -OutFile $dest
~~~
    
    - Execute the installer silently via PowerShell (Event ID 1)
        - Start-Process -FilePath "$env:USERPROFILE\Downloads\7z_installer.exe" -ArgumentList "/S" -Wait
    - Search in Splunk
~~~
index=main sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=1
| xmlkv
| search ParentImage="*powershell.exe"
| table _time, User, ParentImage, Image, CommandLine
~~~

    - Generate Network Traffic (Event ID 3)
        - # Force PowerShell to connect to a web server to generate a Network event
        - Test-NetConnection -ComputerName google.com -Port 443
    - Grand Finale Search
index=main sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" (EventCode=1 OR EventCode=3 OR EventCode=11)
| xmlkv
| eval Action=case(EventCode=1, "EXECUTION", EventCode=3, "NETWORK", EventCode=11, "DOWNLOAD")
| table _time, Action, Image, TargetFilename, DestinationIp, CommandLine
| sort _time
~~~
    




OPNsense

pfSense

NAS
