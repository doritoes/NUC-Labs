Add-DhcpServerv4Scope -Name "branch2" -StartRange 10.0.3.20 -EndRange 10.0.3.250 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -ScopeId (Get-DhcpServerv4Scope -ScopeID 10.0.3.0).ScopeId -DnsDomain xcpng.lab -DnsServer 10.0.1.10 -Router 10.0.3.1
