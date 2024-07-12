# Install-WindowsFeature -Name RSAT-AD-Powershell
Import-Module -Name ActiveDirectory

# Create Folders on E:\
$folderNames = @("Marketing", "Finance", "Development", "IT", "Public")
$rootPath = "E:\"
# Loop through each subdirectory name and create them
foreach ($folderName in $folderNames) {
  $subPath = Join-Path -Path $rootPath -ChildPath $folderName
  New-Item -Path $subPath -ItemType Directory
}

# Public Folder - G Drive
$acl = Get-Acl E:\Public
$identity = (Get-ADGroup -Identity "Domain Users").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
}
Set-Acl E:\Public -AclObject $acl
New-SmbShare -Name "Public" -Path E:\Public

# Marketing Folder - H Drive
$groupName = "MarketingGroup"
$groupOU = "OU=Corp,DC=xcpng,DC=lab"
$groupPath = "$groupName,$groupOU"
try {
    Get-ADGroup -Identity $groupPath
    Write-Host "Group $groupName already exists."
} catch {
    New-ADGroup -Name $groupName -GroupScope Global -SamAccountName $groupName -Path $groupOU
    Write-Host "Group $groupName created."
}
$ouPath = "OU=Marketing,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "MarketingGroup,OU=Corp,DC=xcpng,DC=lab"
Get-ADUser -Filter * -SearchBase $ouPath | Add-ADGroupMember -Identity $groupPath

$acl = Get-Acl E:\Marketing
$identity = (Get-ADGroup -Identity "MarketingGroup,OU=Corp,DC=xcpng,DC=lab").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
}
Set-Acl E:\Marketing -AclObject $acl
New-SmbShare -Name "Marketing" -Path E:\Marketing

# Finance Folder - I Drive
$acl = Get-Acl E:\Finance
$identity = (Get-ADGroup -Identity "OU=Finance,OU=Corp,DC=xcpng,DC=lab").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
}
Set-Acl E:\Finance -AclObject $acl
New-SmbShare -Name "Finance" -Path E:\Finance

# Development Folder - J Drive
$acl = Get-Acl E:\Development
$identity = (Get-ADGroup -Identity "DOU=Development,OU=Corp,DC=xcpng,DC=lab").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
}
Set-Acl E:\Development -AclObject $acl
New-SmbShare -Name "Development" -Path E:\Development -Force`

