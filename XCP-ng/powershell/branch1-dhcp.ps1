Install-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DhcpServerv4Scope -Name "branch1" -StartRange 10.0.1.20 -EndRange 10.0.1.250 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -DnsDomain xcpng.lab -DnsServer 10.0.1.10 -Router 10.0.1.1
