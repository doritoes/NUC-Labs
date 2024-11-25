# Appendix - Manage Windows with Ansible
References: https://docs.ansible.com/ansible/latest/os_guide/index.html

:seedling: This Appendix provides links to valuable information but has yet been fully validated in the Lab.

Requirements:
- PowerShell 5.1 or newer
  - $PSVersionTable.PSVersion
  - Windows Server 2022 has PS 5.1
  - Script to upgrade these: https://github.com/jborean93/ansible-windows/blob/master/scripts/Upgrade-PowerShell.ps1
- .NET 4.0 or newer

Important details:
- The best way to use Ansible is a domain environment with everything configured using GPO (group policy objects)
- In this lab we will use a quick setup on individual machines

# Install Ansible on Linux
For this Lab we can install Ansible on a Desktop or Server.
- `sudo apt update && sudo apt install -y ansible`

# WinRM Method
This is a quick example for setting up a single device. No GPO is used

## WinRM Setup
https://raw.githubusercontent.com/ansible/ansible-documentation/ae8772176a5c645655c91328e93196bcf741732d/examples/scripts/ConfigureRemotingForAnsible.ps1

## WinRM Listener
`winrm quickconfig`

`winrm quickconfig -transport:https`

### WinRM Service

# Windows SSH Method
Using SSH with Windows is experimental.

## Install Win32-OpenSSH

## Configure Win32-OpenSSH Shell

## Configure Ansible for SSH on Windows


# GPO Method
## Enable WinRM traffic in the Network Firewall as Needed
Allow TCP/5985 and TCP/5986 between the systems in the firewall as needed.
## Enable WinRM using GPO
See https://woshub.com/enable-winrm-management-gpo/ and https://www.youtube.com/watch?v=M18yDGAd9TU
- Log in to `the domain controller (`dc-1`)
- create the GPO using administrative powershell
  - `New-GPO -Name "Enable WinRM for Ansible Management" | New-GPLink -Target "DC=xcpng,DC=lab"`
- Open Group Policy Management Console (GPMC)
  - Click Start, search for Group Policy Management and click on it
  - Expand Forest: xcpng.lab
  - Expand Domains: xcpng.lab
  - Right-click **Enable WinRM for Ansible Management** from the tree, then click Edit
  - In the console tree, expand Computer Configuration\Policies\Windows Settings\Security Settings\System Services
  - Find **Windows Remote Service (WS-Managmeent)** and enable automatic startup
    - <ins>Check</ins> Define this policy setting
    - Select **Automatic**
    - Click **OK**
  - Go to Computer Policies -> Preferences -> Control Panel Settings -> Services
  - IN the open space right click, Select **New** -> **Service**
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
    - If you want to allow WinRM connections on all IP addresses, enter '*****' onthe IPv4 filter box
    - Click **Apply** and then click **OK**
  - Create Windows Defender Firewall Rules allowing WinRM connections on the default ports TCP/5985 and TCP/5986
    - Go to Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Windows Firewall with Advanced Security -> Windows Firewall with Advanced Security -> Inbound Rules
    - Right click in the open area and click **New Rule**
      - Select **Prefefined**, and from the dropdown **Windows Remote Management**
      - Review acces to be craeeted: Windows Remote Management rules for ports TCP/5985 and TCP/5986
      - Select **Allow the connection** (default)
      - Click **Finish**
    - Go to Computer Configuration -> Policies -> Administrative Templates -> Windows Components -> Windows Remote Shell
      - Enable **Allow Remote Shell Access**
      - Click **Apply** and then click **OK**
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
      - 🌱 need to work on this; it looks only works on Servers
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

NOTE ununcrypted management connections are NOT recommended. You need to allow unencrypted connections on each target server you want to manage.
- Run `winrm e winrm/config/Listener` to config there is just one listener: transport HTTP
- How to create an https listener: [winrm-https-listener.ps1](powershell/winrm-https-listener.ps1)
  - run on `file-1`
  - `winrm e winrm/config/Listener`
  - Note the port is 5986 for https!
- modify `inventory-win`
  - change the server to `file-1.XCPNG.LAB`
  - change port to 5986
  - `ansible -i inventory-win all -m win_ping`
- now run the playbook with the updated `inventory-win` file to install `Google Chrome`
- `ansible-playbook -i inventory-win win-install-chrome.yml`
