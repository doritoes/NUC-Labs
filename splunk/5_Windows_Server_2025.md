# Windows Server 2025
Prepare a Windows Server 2025 system (I spun up another VM), as we practice configuring things and then work on some common use cases.

NOTE This step assumes you completed the previous [Windows 11](Windows_11.md) steps to configure the Splunk server.

We will be using the Splunk "agent" called the Universal Forwarder (UF)
- harvests local logs and forward them to the Splunk indexer running on the server
- configure UF to pick up more logs so we can practice looking for cyber attacks

NOTE You will need your splunk.com account again to download Splunk plugins and the UF installer

## Configure Windows Server 2025
Set up a Windows Server 2025 test machine.

### Install Sysmon
Sysmon is a Sysinternal tool that can provide a plethora of useful and important logs. We will heavily filter these logs to be able to focus on the important ones. Installing Sysmon now means that when UF is installed, it already has logs to parse.

1. Download Sysmon to the Windows Server 2025 machine
    - https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon
2. Extract the .zip file to C:\Tools
3. Download the config **sysmonconfig-export.xml** from the [SwiftOnSecurity GitHub](https://github.com/SwiftOnSecurity/sysmon-config)
    - Place the config .xml in the same folder (e.g., C:\Tools)
4. Open administrative powershell
    - Navigate to your folder (e.g., C:\Tools)
    - Run: `.\Sysmon64.exe -i sysmonconfig-export.xml -accepteula`
        - Installs Sysmon as a service
        - Uses the SwiftOnSecurity settings to filter out "normal" Windows noise

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
        - Create a local admin for the UF (e.g., **admin** / YourPassword)
        - NOTE This is just for local CLI access on the Windows box
        - Leave **Generate random password** check and click **Next**
    - Deployment Server:
        - Leave this blank and click **Next**
        - NOTE This is for managing 1,000s of forwarders; we don't need it yet
    - Receiving Indexer (Crucial):
        - Hostname or IP: **the IP address of your Ubuntu Server running splunk**)
            - NOTE if you are running DHCP in your Lab, I recommend you set up a DHCP reservation so the IP address doesn't change
        - Port: leave empty, default is 9997
        - Click **Next**
    - Click **Install** and then click **Finish**
3. Update the Splunk Universal Forwarder service to LogOnAs the local system account. Increased permissions are required because we are using SysMon
    - **Start** > **Services**
    - Find **SplunkForwarder** and double-click to modify properties
    - Click **Log On** tab and change to **Local System account**
    - Click **Apply**, **OK**, **OK**
    - Restart the SplunkForwarder service (right-click, Restart)
3. Configure what logs to collect
    - Since we used the default settings, we need to tell UF what logs to collect
    - If we had used **Customize** option we would have selected (and later had to modify it anyways)
        - Application
        - Security
        - System
    - Create the app folder and blank `inputs.conf` file from Adminstrative PowerShell
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
            - View All Files
        - Paste in the contents of inputs.conf [inputs.conf](inputs.conf)
        - Click **File** > **Save**
    - UF only reads this file when it starts up
      - Open administrative PowerShell
      - `Restart-Service SplunkForwarder`
4. Confirming logs arrive
    - Log in to the Splunk Web UI
    - `| metadata type=hosts`
      - If your Windows host name shows up, it is working!
    - `index=_internal host=<WINDOWS_HOSTNAME_HERE>` (usually all lowercase in Splunk)
    - `index=main source="WinEventLog:Security"`

### Optionally, promote it to be a domain controller
See [Appendix - Windows Domain Controller](Appendix-Windows-DC.md)

Because of a bug in Server 2025, you MUST install software before it is promoted to a DC. Once promoted, it cannot install .msi files.

However, promoting to DC seems to break UF. Catch-22.

Attempts to add Splunk Forwarder service to be member of Event Log Readers group broke the Splunk Forwarder service entirely.

If you REALLY want to test on a domain controller, use a Server 2022 DC.

### Test "Backdoor Account" Scenario
In a server environment, attackers often create a local admin account to maintain persistance
- On Server 2025 machine
  - `net user /add BackupAdmin Password123!`
  - `net localgroup administrators BackupAdmin /add`
- Splunk search
  - Added user
    - `index=main source="WinEventLog:Security" EventCode=4720`
  - Added user to group
    - `index=main source="WinEventLog:Security" EventCode=4732`
  - Add fields
~~~
index=main source="WinEventLog:Security" EventCode=4732 
| table _time, ComputerName, member_dn, user_group
~~~

~~~
index=main source="WinEventLog:Security" (EventCode=4720 OR EventCode=4732)
| selfjoin TargetSid, member_id 
| table _time, ComputerName, New_Account_Account_Name, user_group
~~~

### Test "Passsword Reset" Scenario (Event 4724)
Instead of creating a new user, an attacker might hijack an existing local account (like the built-in Guest or a Support account) by resetting its password.

The Command: net user Guest Password123! /active:yes

The Query:

Splunk SPL

index=main source="WinEventLog:Security" EventCode=4724
| table _time, TargetUserName, SubjectUserName, ComputerName
Note: Here, TargetUserName will be the account that was hijacked.

### Test "Guest Group Pivot" Scenario (Event 4732)
Sometimes attackers don't go straight for the "Administrators" group to avoid immediate detection. They might add a user to the "Remote Desktop Users" or "Power Users" group first.

The Query:

Splunk SPL

index=main source="WinEventLog:Security" EventCode=4732 user_group="Remote Desktop Users"
| table _time, member_id, user_group


### Test "Service Injection" Scenario (Event 4697)
An attacker can create a malicious service that runs as SYSTEM.

The Command: sc.exe create BackdoorService binPath= "C:\path\to\malware.exe" start= auto

The Query:

Splunk SPL

index=main source="WinEventLog:System" EventCode=7045
| table _time, Service_Name, Service_Type, Service_Start_Type, Service_Account
Note: In the Security log, this shows up as Event 4697. This is the ultimate "Backdoor" because it survives reboots and runs with highest privileges.







