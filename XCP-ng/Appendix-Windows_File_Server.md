# Appendix - Create Windows File Server

IMPORTANT <ins>Always</ins> use a fixed or static IP for an imortant server like a file server

# Create the Server VM
- From the left menu click **New** > **VM**
  - Select the pool **xcp-ng-lab1**
  - Template: **server2022-lan-prep**
  - Name: fileserver
  - Description: File Server on LAN network
  - CPU: **2** vCPU
  - RAM: **4**GB
  - Topology: Default behavior
  - Disks: Click Add disk
    - 100GB
  - Click **Create**
- The details for the new VM are now displayed
Click **Console** tab
- Answer the language and locale messages
- Select a password for the local Administrator
- Log in
- Accept the network discovery message
- Close the Server Manager promotion for Azure Arc
- Close the Server Manager
- Install Guest Tools (you may not want to!)
  - The Windows tools are not included on the guest-tools.iso
  - Reference: https://xcp-ng.org/docs/guests.html#windows
  - To use the Citrix <ins>drivers</ins>
    - In XO, set the advanced parameter to "Windows Update tools" to ON. This will install the device drivers automatically at next reboot. BUT the management agent still needs to be installed from the Citrix tools installer.
    - https://support.citrix.com/article/CTX235403
    - A Citrix account is required
  - To use community XCP-ng drivers read the article linked above
  - The impact of not having the agent:
    - management of the OS and advanced features like moving the VM to another pool will not be available
- Apply Windows Updates (reboot if needed)
- Change the hostname to fileserver
  - From administrative powershell
    - `Rename-Computer -NewName fileserver`
    - `Restart-Computer`

# Configure Network Settings to be Static
- Log in
- Open administrative powershell
- Set the static IP address and point DNS settings to itself (it's going to be a domain controller).
  - Open an administrative powershell
    - `New-NetIPAddress -IPAddress 192.168.100.11 -DefaultGateway 192.168.100.254 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex`
    - `Set-DNSClientServerAddress -InterfaceIndex(Get-NetAdapter).InterfaceIncex -ServerAddresses 192.168.100.10`

# Join to the Domain
- Start > Settings > System > About
- Scroll down and under Related settings, click Rename this PC (advanced)
- Under the Computer Name tab click Change
- Under Member of, click Domain, enter the domain **xcpng.lab** and then click OK
  - User name: Administrator
  - Password: the password you set on the domain controller

# Create DNS Records
Since we are using the router's DHCP server, not Windows DHCP, we will create DNS records manually.
- Log in to the domain controller
- Open an administative powershell prompt
  - `Add-DnsServerResourceRecordA -Name "fileserver" -ZoneName "xcpng.lab" -AllowUpdateAny -IPv4Address "192.168.100.11" -TimeToLive 01:00:00`
  - `Add-DnsServerResourceRecordPtr -Name "11" -ZoneName "100.168.192.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "fileserver.xcpng.lab"

# Configure the Second Disk
- Start > Create and format hard disk partitions
- You wil be prompted to intialze the disk (Disk 1)
  - Accept GPT (GUID Partition Table)
  - Click OK
- Right-click Disk 1 and then click **New Simple Volume**
  - Follow the wizard and set the volume label to **NETDRIVE**

# Create a File Shares
Overview:
- icacls command sets permissions on the E: drive.
- New-SmbShare creates the network share named "SharedFolder".
- New-PSDrive creates a persistent mapped drive letter (G:) for the share.
- -Persist makes the mapping survive reboots.
- -Force overwrites an existing drive mapping (if any).
- -Path specifies the network share path.

### Create Folders for Each Share
- On the E: drives create folders named
  - Marketing
  - Finance
  - Development
  - IT
  - Public

### Create G: Drive for Public
1. Grant Share Permissions
    - `icacls E:\ /grant Everyone:(OI)(CI)F`
    - Grant Full Control to Everyone
2. Create Share
    - `New-SmbShare -Name "SharedFolder" -Path E:\ -Force`
    - Create share even if it exists
3. Persistently Map G: drive for uers
    - `mapshareddrive.ps1`
```
New-PSDrive -Name G -Persist -Force -Path "\\fileserver.xcpng.lab\SharedFolder"
```
    - run the script


### Create H: Drive for Marketing

### Create I: Drive for Finance

### Create J: Drive for Development
To create a share for a specific OU
1. Grant Share Permissions
~~~
icacls E:\Development /grant "Domain Users:(OI)(CI)RX"  # Grant Read & Execute to Domain Users (temporary for access)
icacls E:\Development /grant "xcpng.lab\Development Users:(OI)(CI)F"  # Grant Full Control to Development OU users
~~~
    - We grant temporary Read & Execute permissions to "Domain Users" to allow initial access for assigning permissions.
    - We then grant "Full Control" permissions to the "Development Users" group within the "xcpng.lab" domain.
2. Remove temporary permissions
~~~
icacls E:\Development /remove "Domain Users:(OI)(CI)RX" 
~~~

3. Persistently Map G: drive for uers
    - `mapshareddrive.ps1`
```
New-PSDrive -Name G -Persist -Force -Path "\\fileserver.xcpng.lab\SharedFolder"
```
    - run the script

### Create K: Drive for IT




# Create a Shared Drive

# Create DNS records
- Open an administrative powershell
  - `Add-DnsServerResourceRecordA -Name "router" -ZoneName "xcpng.lab" -AllowUpdateAny -IPv4Address "192.168.100.254" -TimeToLive 01:00:00`
  - `Add-DnsServerResourceRecordPtr -Name "254" -ZoneName "100.168.192.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "router.xcpng.lab"

