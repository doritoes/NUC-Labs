Import-Module ActiveDirectory
New-ADReplicationSubnet -Name "10.0.3.0/24"
Add-DNSServerPrimaryZone -NetworkID "10.0.3.0/24" -ReplicationScope "Forest"
Add-DnsServerResourceRecordA -Name "firewall3-lan" -ZoneName "xcpng.lab" -AllowUpdateAny -IPv4Address "10.0.3.1" -TimeToLive 01:00:00
Add-DnsServerResourceRecordPtr -Name "1" -ZoneName "3.0.10.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "firewall3-lan.xcpng.lab"
