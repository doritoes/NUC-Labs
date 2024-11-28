Import-Module ActiveDirectory
New-ADReplicationSubnet -Name "10.0.1.0/24"
Add-DNSServerPrimaryZone -NetworkID "10.0.1.0/24" -ReplicationScope "Forest"
Add-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru
Add-DnsServerForwarder -IPAddress 8.8.4.4 -PassThru
Add-DnsServerResourceRecordA -Name "firewall1-lan" -ZoneName "xcpng.lab" -AllowUpdateAny -IPv4Address "10.0.1.1" -TimeToLive 01:00:00
Add-DnsServerResourceRecordPtr -Name "1" -ZoneName "1.0.10.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "firewall1-lan.xcpng.lab"
