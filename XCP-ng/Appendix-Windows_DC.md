# Convert Windows Server to Domain Controller
NOTE A Windows Server evaluation version configured as a domain controller <ins>cannot be licensed and converted to production</ins>.

IMPORTANT <ins>Always</ins> use a fixed or static IP for a domain controller.

# Create the Server VM
- From the left menu click **New** > **VM**
  - Select the pool **xcp-ng-lab1**
  - Template: **server2022-lan-prep**
  - Name: server2022dc
  - Description: Domain controller on LAN network
  - CPU: **2** vCPU
  - RAM: **4**GB
  - Topology: Default behavior
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
- Change the hostname to server2022dc
  - From administrative powershell
    - `Rename-Computer -NewName server2022dc`
    - `Restart-Computer`

# Configure Network Settings to be Static
- Log in
- Set the static IP address and point DNS settings to itself (it's going to be a domain controller).
  - Open an administrative powershell
    - `New-NetIPAddress -IPAddress 192.168.100.10 -DefaultGateway 192.168.100.254 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex`
    - `Set-DNSClientServerAddress -InterfaceIndex(Get-NetAdapter).InterfaceIncex -ServerAddresses 192.168.100.10`

# Configure as Domain Controller
- Open an administrative powershell
  - `Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools`
  - `Install-ADDSForest -DomainName xcpng.lab -DomainNetBIOSName AD -InstallDNS`
  - Select a password for SafeModeAdministratorPassword (aka DSRM = Directory Services Restore Mode)
  - Confirm configuring server as Domain Controller and rebooting
- Wait as the settings are applied and the server is rebooted
- Wait some more as "Applying Computer Settings" gets the domain controller ready

# Configure Sites and Services Subnets and DNS
- Log in to the new domain controller
- Open an administrative powershell
  - `Import-Module ActiveDirectory`
  - `New-ADReplicationSubnet -Name "192.168.100.0/24"`
  - `Add-DNSServerPrimaryZone -NetworkID "192.168.100.0/24" -ReplicationScope "Forest"`
  - `Add-DnsServerForwarder -IPAddress 9.9.9.9 -PassThru`

# Create DNS records
- Open an administrative powershell
  - `Add-DnsServerResourceRecordA -Name "router" -ZoneName "xcpng.lab" -AllowUpdateAny -IPv4Address "192.168.100.254" -TimeToLive 01:00:00`
  - `Add-DnsServerResourceRecordPtr -Name "254" -ZoneName "100.168.192.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "router.xcpng.lab"

# Create Users in the Domain
References:
- https://blog.netwrix.com/2018/06/07/how-to-create-new-active-directory-users-with-powershell/
- https://www.fakepersongenerator.com/

Steps:
- Create OUs
  - New-ADOrganizationalUnit -Name "Corp" -Path "DC=xcpng,DC=lab"
  - New-ADOrganizationalUnit -Name "Support" -Path "OU=Corp,DC=yourdomain,DC=com"
  - New-ADOrganizationalUnit -Name "Development" -Path "OU=Corp,DC=yourdomain,DC=com"
  - New-ADOrganizationalUnit -Name "Sales" -Path "OU=Corp,DC=yourdomain,DC=com"
  - New-ADOrganizationalUnit -Name "Marketing" -Path "OU=Corp,DC=yourdomain,DC=com"
  - New-ADOrganizationalUnit -Name "Finance" -Path "OU=Corp,DC=yourdomain,DC=com"
- Copy the [domain_users.csv](domain_users.csv) file to `C:\domain_users.csv`
  - the CSV file must be in UTF-8 encoding
- Copy the [domain_users.ps1](domain_users.ps1) file to `C:\domain_users.ps1`
- Run the script
  - `powershell.exe -File C:\domain_users.ps1 -ExecutionPolicy Bypass`
- Add the network manager's second (elevated) account domain permissions
  - `Add-ADGroupMember -Identity "Domain Admins" -Members "Juliette.Larocco2"`
- Make "Support" users account operators
  - Copy the [access.ps1](access.ps1) file to `C:\access.ps1`
  - `powershell.exe -File C:\access.ps1 -ExecutionPolicy Bypass`
- Make "Support" and "Development" users members of "Remote Desktop Users" group
  - [rdp_users.ps1](rdp_users.ps1)
- Important: By default RDP access is limited to the Administrators group
  - You also need to open gpmc.msc on the domain controller and edit the Default Domain Policy object
  - Navigate to Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\User Rights Assignment\Allow logon through Remote Desktop Services
    - Enable the policy
    - Add the group Remote Desktop Users group and/or a user to the list
    - Allow time for the policy to applied and distributed

# Next Steps
## DHCP Server
Converting from DHCP by the router to using the domain controller for DHCP is out of the scope of this lab. It's a worthy challenge, however.

## Join Windows Systems to the Domain
https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/deployment/join-a-computer-to-a-domain
- Make sure the computer has the name you want
  - Rename using the the GUI or the usual powershell commmands
    - `Rename-Computer -NewName tingtings`
    - `Restart-Computer`
- Windows 10 system
  - Open Network & Settings
  - Under Ethernet click Properties
  - Click Change adapter optionss
  - Select Network profile Private
  - Edit the Ethernet adapter and click Properties
    - Click TCP/IPv4 and then click Properties
    - Leave at Obtain and IP address automatically
    - Change to Use the following DNS server addresses: 192.168.100.10
    - Close the windows
  - Start > Settings > System > About
  - Scroll down and under Related settings, click Rename this PC (advanced)
  - Click Network ID
    - This comuter is part of a business network ...
    - My company user a network with a domain
    - Username: Administrator
    - Password: the domain controller's user "Administrator" password
    - Domain name: XCPNG.LAB
    - If the computer doesn't have an account you will be prompted to enter the computer name and domain again
    - Next, enter the credentials of the account with permissions to join the domain
      - User name: Administrator
      - Password: the domain controller's user "Administrator" password
      - Domain name: XCPNG.LAB
    - Since this is a lab, approve adding the domain user account to the computer
    - Since you're adding the domain admin, it's OK to allow it Administrator on the workstation
  - Restart the computer
  - Log in as the domain Administrator account
  - DNS won't work correctly in this state. Either configure the domain controller to do DHCP and intergrate with DNS, or set static IPs on your workstations and add them using the powershell or the administratives tools
  - Optionally install RSAT: Remote Access Management Tools
    - Manage Optional Features
    - Add a Feature
    - Search for RSAT
    - Select all the features you want
    - Click Add
    - Click Start then type MMC
      - Some of the MMC snapins are listed
    - Open MMC (Start > Run for example)
      - File > Add/Remove Snap-in
      - Add snap-ins you desire (e.g. Active Directory Users and Computers)
    - Start > Remote Access Management
- Windows Server
  - Open Network & Settings
  - Under Ethernet click Properties
  - Click Change adapter options 
  - Edit the Ethernet adapter and click Properties
    - Click TCP/IPv4 and then click Properties
    - Change to Use the following IP address
      - IP address: 192.168.100.11 (.11 through .19 are available)
    - Change to Use the following DNS server addresses: 192.168.100.10
    - Close the windows
  - Meanwhile, run this on the domain controller:
    -  `Add-DnsServerResourceRecordA -Name "server1" -ZoneName "xcpng.lab" -AllowUpdateAny -IPv4Address "192.168.100.11" -TimeToLive 01:00:00`
  - `Add-DnsServerResourceRecordPtr -Name "11" -ZoneName "100.168.192.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "server1.xcpng.lab"
  - Start > Settings > System > About
  - Scroll down and under Related settings, click Rename this PC (advanced)
  - Under the Computer Name tab click Change
  - Under Member of, click Domain, enter the domain xcpng.lab and then click OK
    - User name: Administrator
    - Password: the password you set on the domain controller
  - Click OK on the Computer Name/Domain Changes dialog box
  - Under About click Rename your PC and rename it server1
  - Restart the computer
  - Log in as the domain Administrator account
    - AD\Administrator
    - "AD" is the netbios name of xcpng.lab
  - For extra points
    - set up a file share on server1 and access it from the Windows 10 workstation
    - install an FTP server like FileZilla server on server1 - https://filezilla-project.org/download.php?type=server
    - install IIS and configure a web site on server - https://beehosting.pro/kb/how-to-install-and-configure-iis-web-server-on-windows-server-2022/
    - Join a Ubuntu desktop to the Active Directory domain - https://medium.com/@daryl-goh/how-to-join-a-linux-ubuntu-machine-to-windows-active-directory-domain-a5563ccc4844
