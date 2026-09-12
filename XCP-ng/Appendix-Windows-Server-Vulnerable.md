# Enable Vulnerable Services on Windows Server
For pentesting, we will configure a few things to find. [7_Pentesting_Lab.md](XCP-ng/7_Pentesting_Lab.md)

## Enable SMB Server role
```Install-WindowsFeature -Name FS-FileServer -IncludeManagementTools```

You can also do the same using Server Manager to add roles and features.

## Enable SMBv1 (Dangerous)
Enabling Legacy CIFS / SMB1 is Not Recommended. SMB1/CIFS contains unpatched vulnerabilities and is disabled by default in modern Windows environments. Use modern SMB features

```Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol```
