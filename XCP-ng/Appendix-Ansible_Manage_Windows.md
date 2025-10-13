# Appendix - Manage Windows with Ansible
References: https://docs.ansible.com/ansible/latest/os_guide/index.html

Requirements:
- PowerShell 5.1 or newer
  - $PSVersionTable.PSVersion
  - Windows Server 2022 has PS 5.1
  - Script to upgrade these: https://github.com/jborean93/ansible-windows/blob/master/scripts/Upgrade-PowerShell.ps1
- .NET 4.0 or newer

Important details:
- The best way to use Ansible is a domain environment with everything configured using GPO (group policy objects)
- Many people use usernames and password for authentication because Certificates a Hard(TM), or use unencrypted http (bad!)
- Using WinRM with Kerberos is the method tested in this Lab, using self-signed certificates
  - See one example of issuing certificates here: https://www.darkoperator.com/blog/2015/3/24/bdvjiiw1ybzfdjulc5pprgpkm8os0b

# GPO Method
## Enable WinRM traffic in the Network Firewall as Needed
Allow TCP/5985 and TCP/5986 between the systems in the firewall as needed. In the example below we omitted the DMZ Windows server.
- Allow TCP port 5985 (http-based) and port 5986 (https-based) between the systems you will remote from/to
  - Example Lab_Policy:
    - Add rule to Core Services section
      - Name: Allow WinRM for Ansible
      - Source: Manager (you would use "support" there, and log in as Juliette.Larocco instead of "Lab")
      - Destinations: LAN_Networks_NO_NAT
      - Services:
        - New > TCP: winrm_http_5985, port 5985
        - New > TCP: winrm_https_5986, port 5986
      - Action: Accept
      - Track: Log > Accounting
  - Example Lab_Policy_Branches:
    - Add rule to Core Services section
      - Name: Allow WinRM for Ansible
      - Source: support
      - Destination: LAN_Networks_NO_NAT
      - Services:
        - winrm_http_5985
        - winrm_https_5986
      - Action: Accept
      - Track: Log > Accounting

## Enable WinRM using GPO
See https://woshub.com/enable-winrm-management-gpo/ and https://www.youtube.com/watch?v=M18yDGAd9TU
- Log in to `the domain controller (`dc-1`)
- create the GPO using administrative powershell
  - `New-GPO -Name "Enable WinRM for Ansible Management" | New-GPLink -Target "DC=xcpng,DC=lab"`
- Open Group Policy Management Console (GPMC)
  - Click **Start**, search for **Group Policy Management** and click on it
  - Expand Forest: xcpng.lab
  - Expand Domains: xcpng.lab
  - Right-click **Enable WinRM for Ansible Management** from the tree, then click **Edit**
  - In the console tree, expand Computer Configuration\Policies\Windows Settings\Security Settings\System Services
  - Find **Windows Remote Service (WS-Managmeent)** and enable automatic startup
    - <ins>Check</ins> Define this policy setting
    - Select **Automatic**
    - Click **Apply** and then click **OK**
  - Go to Computer Configuration -> Preferences -> Control Panel Settings -> Services
  - In the open space, right-click, Select **New** -> **Service**
  -   Enter the service name: **WinRM**
  - Select the **Recovery** tab
    - First failure: Restart the Service
    - Second failure: Restart the Service
    - Subsequent failure: Restart the Service
    - Restart file counter after: 0 days
    - Restart service after : 1 minutes
    - Click **Apply** then click **OK**
  - Go to Computer Configuration -> Policies -> Administrative Templates -> Windows Components -> Windows Remote Management (WinRM) -> WinRM Service
  - Enable **Allow remote server management through WinRM**
    - In the Ipv4/IPv6 filter box, you can specify IP addresses or subnetworks, on which WinRM connections must be listened to
    - If you want to allow WinRM connections on all IP addresses, enter '*****' (single asterisk) in the IPv4 filter box
    - Click **Apply** and then click **OK**
  - Create Windows Defender Firewall Rules allowing WinRM connections on the default ports TCP/5985 and TCP/5986
    - Go to Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Windows Firewall with Advanced Security -> Windows Firewall with Advanced Security -> Inbound Rules
    - Right-click in the open area and click **New Rule**
      - Select **Predefined**, and from the dropdown **Windows Remote Management**
      - Review acces to be created: Windows Remote Management rules for ports TCP/5985 and TCP/5986
      - Select **Allow the connection** (default)
      - Click **Finish**
    - Go to Computer Configuration -> Policies -> Administrative Templates -> Windows Components -> Windows Remote Shell
      - Enable **Allow Remote Shell Access**
      - Click **Apply** and then click **OK**
- Enabling https
  - Sadly as of this writing there is no ay to enable HTTPS using GPO
  - There is the command to enable it; you could place it in a login script to enable WinRM and make it only use HTTPS
    - `winrm quickconfig -transport:https`
    - this requires a certificate to already be created
- Testing
  - Log in to a workstation (`branch1-1`)
    - Wait for group policy to roll out, or run `gpupdate /force`
    - To check that WinRM settings on the computer are configured thorugh GPO
      - open administrative shell
        - `winrm e winrm/config/listener`
        - `Test-WsMan localhost`
  - Log in to a workstation (`branch2-1`)
    - Wait for group policy to roll out, or run `gpupdate /force`
    - To check that WinRM settings on the computer are configured thorugh GPO
      - open administrative shell
        - `winrm e winrm/config/listener`
        - `Test-WsMan localhost`
  - Log in to the domain controller (`dc-1`)
    - To check that WinRM settings on the computer are configured thorugh GPO
      - open administrative shell
        - `winrm e winrm/config/listener`
        - `Test-WsMan localhost`
    - Remote access test:
      - In Lab testing, this only worked on Servers, not workstations. HOWEVER, able to use Ansible playbooks on workstations too
      - From `dc-1`
        - `Test-WsMan localhost` - works
        - `Test-WsMan file-1` - works
        - `Test-WsMan sql-1` - works
        - `Test-WsMan idc-1` - works
        - `Test-WsMan dmz-iis` - works IF the firewall rules allow
        - `Test-WsMan dc-1` - fails - WinRM client sent a request to an HTTP server and got a response saying the requested HTTP URL was not available. This is usually returned a HTTP server that does not support the WS-Management protocol.
        - `Test-WsMan branch1-1` - fails connection
        - `Test-WsMan branch2-1` - fails connection
        - `Test-WsMan branch3-1` - fails connection
      - From `branch1-1`
        - `Test-WsMan localhost` - works
        - `Test-WsMan file-1` - works
        - `Test-WsMan sql-1` - works
        - `Test-WsMan idc-1` - works
        - `Test-WsMan dmz-iis` - works IF the firewall rules allow
        - `Test-WsMan dc-1` - works
        - `Test-WsMan branch2-1` - fails connection
        - `Test-WsMan branch3-1` - fails connection
        - Test the WinRM point is opened on the remote computer
    - `Test-NetConnection -ComputerName dc-1 -Port 5985`
    - Test Remote session 
      - From privileged powershell
      - `enter-pssession dc-1`

## Playbooks
- Allow unencrypted WinRM traffic on `dc-1` for testing
  - `Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value true`
- Log in to `manager` and open WSL shell
- Install kerberos
  - `sudo apt install -y krb5-user`
- Create inventory file [inventory-win](ansible/inventory-win)
- Get a kerberos ticket
  - `kinit juliette.larocco2@XCPNG.LAB`
  - `klist`
- Test Ansible authentication
  - `ansible -i inventory-win windows -m ping`
- Create playbook to install Google Chrome
  - [win-install-chrome.yml](ansible/win-install-chrome.yml)
  - `ansible-playbook -i inventory-win win-install-chrome.yml`
- Clean up: `kdestroy`

NOTE Unencrypted management connections are NOT recommended. You can enable self-signed certificates to enable encrypted management connections.
- Run `winrm e winrm/config/Listener` to confirm there is just one listener: transport HTTP
- How to create an https listener with a self-signed certificate: [winrm-https-listener.ps1](powershell/winrm-https-listener.ps1)
  - run on `file-1`: `powershell -ExecutionPolicy Bypass winrm-https-listener.ps1`
  - `winrm e winrm/config/Listener`
  - NOTE the port is 5986 for https!
  - NOTE you can also use the command `winrm quickconfig -transport:https` to enable https (only), but this requires a certificate to already exist
- modify `inventory-win`
  - change the server to `file-1.XCPNG.LAB`
  - change port to 5986
  - `ansible -i inventory-win all -m win_ping`
- now run the playbook with the updated `inventory-win` file to install `Google Chrome`
- `ansible-playbook -i inventory-win win-install-chrome.yml`

In testing, I was able to run `winrm-https-listener.ps1` on workstations (branch1-1, branch2-1, branch3-1), then add them to the `inventory-win` file, and install Chrome.
