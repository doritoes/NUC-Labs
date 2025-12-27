# Windows 11
Prepare a Windows 11 system (I spun up another VM running Windows 11), as we practice configuring things and then work on some common use cases.

We will be using the Splunk "agent" called the Universal Forwarder (UF)
- harvests local logs and forward them to the Splunk indexer running on the server
- configure UF to pick up more logs so we can practice looking for cyber attacks

NOTE You will need your splunk.com account again to download Splunk plugins and the UF installer

## Configuring Splunk Server
### Configure the Splunk Listener
1. Open port 9997
    - Log into Splunk Web UI
    - **Settings** > **Data** > **Forwarding and Receiving**
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
    - **Settings** > **System** > **Server Controls** > **Restart Splunk**
    - or command line `sudo /opt/splunk/bin/splunk restart`

## Configure Windows 11
Set up a Windows 11 test machine
- Install Google Chrome on it (will be demonstrating with both Chrome and Edge)

### Install Sysmon
Sysmon is a Sysinternals tool that can provide a plethora of useful and important logs. We will heavily filter these logs to be able to focus on the important ones. Installing Sysmon now means that when UF is installed, it already has logs to parse.

1. Download Sysmon to the Windows 11 machine
    - https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon
2. Extract the .zip file to C:\Tools
3. Download the config **sysmonconfig-export.xml** from the [SwiftOnSecurity GitHub](https://github.com/SwiftOnSecurity/sysmon-config)
    - Place the config .xml in the same folder (e.g., C:\Tools)
4. Open administrative powershell
    - Navigate to your folder (e.g., C:\Tools)
    - Run: `.\Sysmon64.exe -i sysmonconfig-export.xml -accepteula`
        - Installs Sysmon as a service
        - Uses the SwiftOnSecurity settings to filter out "normal" Windows noise
    - Confirm/Add to the `inputs.conf` file:
        - [WinEventLog://Microsoft-Windows-Sysmon/Operational]
        - disabled = 0
        - index = main
        - renderXml = 1
        - sourcetype = XmlWinEventLog:Microsoft-Windows-Sysmon/Operational
    - If you changed anything,restart the forwarder
        - `Restart-Service SplunkForwarder`
        
### Install UF for Windows
1. Download the Windows 64-bit MSI file
    - https://splunk.com/en_us/download/universal-forwarder.html
    - You need to log in to splunk.com
    - Windows tab > 64-bit > Download Now
    - Accept the terms
2. Launch the installer named similar to `splunkforwarder-10.0.2-xxxxxx-windows-x64`
    - Accept the agreement
    - Use this UniversalForwarder with: **An on-premises Splunk Enterprise instance**
    - Click **Next**
    - Create Credentials
        - Create a local admin for the UF (e.g., admin / YourPassword)
        - NOTE This is just for local CLI access on the Windows box
        - Leave **Generate random password** checked and click **Next**
    - Deployment Server:
        - Leave this blank and click **Next**
        - NOTE This is for managing 1,000s of forwarders; we don't need it yet
    - Receiving Indexer (Crucial):
        - Hostname or IP: **the IP address of your Ubuntu Server running splunk**)
            - NOTE if you are running DHCP in your Lab, I recommend you set up a DHCP reservation so the IP address doesn't change
        - Port: leave empty, default is 9997
        - Click **Next**
    - Click **Install** and then click **Finish**
3. Update the Splunk Universal Forwarder service to LogOnAs the **local system account**
    - Increased permissions are required because we are using SysMon
    - **Start** > **Services**
    - Find **SplunkForwarder** and double-click to modify properties
    - Click **Log On** tab and change to **Local System account**
    - Click **Apply**, **OK**, **OK**
    - Restart the SplunkForwarder service (right-click, **Restart**)
4. Configure what logs to collect
    - Since we used the default settings, we need to tell UF what logs to collect
    - If we had used **Customize** option we would have selected (and later had to modify it anyways)
        - Application
        - Security
        - System
    - Create the app folder and blank `inputs.conf` file from Administrative PowerShell
~~~
# 1. Create the directory
$labPath = "C:\Program Files\SplunkUniversalForwarder\etc\apps\lab\local"
New-Item -Path $labPath -ItemType Directory -Force
# 2. Set Permissions (Ensures the UF service can read your configs)
$acl = Get-Acl $labPath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $labPath $acl
# 3. Create the empty inputs.conf file
New-Item -Path "$labPath\inputs.conf" -ItemType File -Force
~~~

    - Open **Notepad** as an **Administrator**
        - Open `C:\Program Files\SplunkUniversalForwarder\etc\apps\lab\local\inputs.conf`
        - Paste in the contents of inputs.conf [inputs.conf](inputs.conf)
        - Click **File** > **Save**
    - UF only reads this file when it starts up
      - Open administrative PowerShell
      - `Restart-Service SplunkForwarder`
5. Confirming logs arrive
    - Log in to the Splunk Web UI
    - `| metadata type=hosts`
      - If your Windows host name shows up, it is working!
    - `index=_internal host=<WINDOWS_HOSTNAME_HERE>` (usually all lowercase in Splunk)
    - `index=main source="WinEventLog:Security"`

### Test "Insider Threat" Scenario
- Local Console
  - Lock the screen and attempt to log in with a wrong password 3 or 4 times
    - NOTE Logging in with a PIN doesn't populate the TargetUserName field(!) It will show the Sub_status 0xc0000380 STATUS_SMARTCARD_SILENT_CONTEXT
  - Log in with the correct password
  - Open the Splunk search bar
  - Set the Time Picker to "Last 15 minutes"
  - Run the following search to find the failures:
  - `index=main source="WinEventLog:Security" EventCode=4625`
  - Note the **Interesting Fields** on the left
    - Account_Name: The account they tried to hack
    - Logon_Type: 2 (Interactive) or 7 (Unlock)
    - IpAddress: empty, missing or 127.0.0.1 for console login
    - Status: The hex code for why it failed (e.g., 0xc000006d means bad password)
    - Sub_status: 0xC000006A (STATUS_WRONG_PASSWORD)
- RDP to Win 11 computer
    - For example if the local username is "Lab", enter the username ".\lab"
    - Try wrong password 3 or 4 times
    - Log in with the correct password
    - Open the Splunk search bar
    - Set the Time Picker to "Last 15 minutes"
    - Run the following search to find the failures:
      - `index=main source="WinEventLog:Security" EventCode=4625`
      - Note the **Interesting Fields** on the left
        - Account_Name: The account they tried to hack
        - Logon_Type: 3 (Network Login) means NLA negotiated credentials before RDP fully opened; Type 10 is what we classically expected for RDP
        - Source_Network_Address: the IP address you tried to log in <ins>from</ins>
        - Status: The hex code for why it failed (e.g., 0xc000006d means bad password)
        - Sub_status: 0xC000006A (STATUS_WRONG_PASSWORD)
      - Use a "friendly" query that uses the Windows Plugin
```
index=main EventCode=4625 
| table _time, user, src_ip, Logon_Type, status
```

- Confirm Successful Logins
```
index=main EventCode=4624
| table _time, user, src_ip, Logon_Type
```

NOTE You will see the service accounts like DWM-4 (Desktop Window Manager) and UMDF-4 (User Mode Driver Framework) logging in. Look up what these are used for. It's a fun read.

### Test "Persistence" Scenario (New User Account)
Imaging the attacker has got into the system. They create another account that they control to attain persistent access.
- On the Windows 11 machine open an administrative command prompt
- Create a new user: `net user LabVictim Splunk123! /add"
- In Splunk search bar
    - query: `index=main source="WinEventLog:Security" EventCode=4720`
- Identify the name of the user that was created and the user that created them

### Test "Wiping the Evidence" Scenario (Log Clearing)
IMPORTANT This is a Priority 1 alert in any real-world SOC
- On Windows 11 machine open an administrative command prompt
- Run the command: `wevtutil cl Security`
  - This clears the Security log (!)
- Detect it in Splunk search
```
index=main EventCode=1102
| table _time, user, host, msg
```

### Test "PowerShell Execution" Scenario (Living Off the Land)
NOTE Most modern attacks don't use .exe files anymore, they use PowerShell to run commands directly in memory

First we will turn on enhanced logging to track process creating and PowerShell Script Block logging.
- On Windows 11 machine: **Start** > **gpedit.msc**
  - Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > System Audit Policies > Detailed Tracking
  - In right-hand page double click **Audit Process Creation**
  - Check **Configure the folllowing audit events** and both **Succcess** and **Failure**
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

Now we can test the scenario
- Close out all remaining PowerShell Windows
- Open PowerShell
- Run: notepad.exe "C:\splunk_test.txt"
  - It will display an error because the file doesn't exist; close it out
- Run: `Write-Host "Simulating Malware Download" -ForegroundColor Red`
- Run: `Get-Service | Where-Object {$_.Status -eq "Stopped"}`
- Detect it in Splunk search
~~~
index=main EventCode=4688 process_name!="splunk-powershell.exe"
| search "powershell.exe"
| table _time, user, parent_process_name, New_Process_Name, Process_Command_Line
~~~

~~~
index=main EventCode=4104
~~~

~~~
index=main EventCode=4104
| xmlkv
| table _time, ScriptBlockText
~~~

### Track Browser Launch (and any funny command line arguments)
NOTE this only tracks Chrome and Edge.
- On the Windows 11 machine, open Chrome and Edge, then browse the Internet
- Search in Splunk
~~~
index=main EventCode=4688 (process_name="chrome.exe" OR process_name="msedge.exe")
| table _time, user, process_name, CommandLine
~~~

- Note that no browsing history is shown, only the process creation


### Test the "Kill Chain" Scenario (Track the download the execution, and forensics)


#### Track the Chrome (or Edge) download (Event ID 11)
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
~~~
index=main source="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=11
| xmlkv
| table _time, Image, TargetFilename
~~~

- Simulate downloading malware by downloading 7-Zip installer from PowerShell
  - Download an exe (Event ID 11)
  - `Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2301-x64.exe" -OutFile "$env:USERPROFILE\Downloads\Project_X_Payload.exe"`
- Execute the installer silently via PowerShell (Event ID 1)
  - Start-Process -FilePath "$env:USERPROFILE\Downloads\Project_X_Payload.exe" -ArgumentList "/S" -Wait
  - NOTE you are prompted by UAC to allow the changes. A real attack has methods to disable UAC.
- Search in Splunk
~~~
index=main source="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=1
| xmlkv
| search ParentImage="*powershell.exe"
| table _time, User, ParentImage, Image, CommandLine
~~~

- Generate Network Traffic to simulate malware calling home (Event ID 3)
  - Test-NetConnection -ComputerName google.com -Port 443
- Grand Finale Search
~~~
index=main source="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" (EventCode=1 OR EventCode=3 OR EventCode=11)
| xmlkv
| eval Action=case(EventCode=1, "EXECUTION", EventCode=3, "NETWORK", EventCode=11, "DOWNLOAD")
| table _time, Action, Image, TargetFilename, DestinationIp, CommandLine
| sort _time
~~~
