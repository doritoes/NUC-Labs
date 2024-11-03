Add-DhcpServerv4Scope -Name "branch2" -StartRange 10.0.2.20 -EndRange 10.0.2.250 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -DnsDomain xcpng.lab -DnsServer 10.0.1.10 -Router 10.0.2.1
