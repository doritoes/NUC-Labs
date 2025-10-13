Install-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DhcpServerInDC -DnsName dc-1.xcpng.lab -IPAddress 10.0.1.10
Add-DhcpServerv4Scope -Name "branch1" -StartRange 10.0.1.20 -EndRange 10.0.1.250 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -ScopeId (Get-DhcpServerv4Scope -ScopeID 10.0.1.0).ScopeId -DnsDomain xcpng.lab -DnsServer 10.0.1.10 -Router 10.0.1.1
