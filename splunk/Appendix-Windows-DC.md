# Convert Windows Server to Domain Controller
NOTE A Windows Server evaluation version configured as a domain controller <ins>cannot be licensed and converted to production</ins>.

IMPORTANT <ins>Always</ins> use a fixed or static IP for a domain controller.

# Create a Windows Server 2025 VM or System
- Install Windows Server 2025
- Apply Windows Updates (reboot if needed)
- Change the hostname to server2025dc
  - From administrative powershell
    - `Rename-Computer -NewName server2025dc`
    - `Restart-Computer`

# Configure Network Settings to be Static
- Log in
- Set the static IP address and point DNS settings to itself (it's going to be a domain controller).
  - Open an administrative powershell (modify these examples for your Lab)
    - `New-NetIPAddress -IPAddress 192.168.100.10 -DefaultGateway 192.168.100.254 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex`
    - `Set-DNSClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses 192.168.100.10`

# Configure as Domain Controller
- Open an administrative powershell (modify these examples for your Lab)
  - `Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools`
  - `Install-ADDSForest -DomainName splunk.lab -DomainNetBIOSName SPLUNK -InstallDNS`
  - Select a password for SafeModeAdministratorPassword (aka DSRM = Directory Services Restore Mode)
  - Confirm configuring server as Domain Controller and rebooting
- Wait as the settings are applied and the server is rebooted
- Wait some more as "Applying Computer Settings" gets the domain controller ready

# Configure Sites and Services Subnets and DNS
- Log in to the new domain controller
- Open an administrative powershell (modify these examples for your Lab)
  - `Import-Module ActiveDirectory`
  - `New-ADReplicationSubnet -Name "192.168.100.0/24"`
  - `Add-DNSServerPrimaryZone -NetworkID "192.168.100.0/24" -ReplicationScope "Forest"`
  - `Add-DnsServerForwarder -IPAddress 9.9.9.9 -PassThru`

# Create DNS records
- Open an administrative powershell (modify these examples for your Lab)
  - `Add-DnsServerResourceRecordA -Name "router" -ZoneName "xcpng.lab" -AllowUpdateAny -IPv4Address "192.168.100.254" -TimeToLive 01:00:00`
  - `Add-DnsServerResourceRecordPtr -Name "254" -ZoneName "100.168.192.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "router.xcpng.lab"
  
