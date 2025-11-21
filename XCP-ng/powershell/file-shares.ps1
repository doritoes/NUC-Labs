Install-WindowsFeature -Name RSAT-AD-Powershell
Import-Module -Name ActiveDirectory

# Create Folders on F:\
$folderNames = @("Marketing", "Finance", "Development", "IT", "Public")
$rootPath = "F:\"
# Loop through each subdirectory name and create them
foreach ($folderName in $folderNames) {
  $subPath = Join-Path -Path $rootPath -ChildPath $folderName
  New-Item -Path $subPath -ItemType Directory
}

#### Public Folder - G Drive
# Set folder permissions
$acl = Get-Acl F:\Public
$identity = (Get-ADGroup -Identity "Domain Users").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl F:\Public -AclObject $acl
# share the folder and fix permissions
New-SmbShare -Name "Public" -Path F:\Public
Grant-SmbShareAccess -Name "Public" -AccountName "Domain Users" -AccessRight Full -Force
Revoke-SMBShareAccess -Name "Public" -AccountName "Everyone" -Force

#### Marketing Folder - H Drive
# create group and add users
$groupName = "MarketingGroup"
$groupOU = "OU=Marketing,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "$groupName,$groupOU"
try {
    Get-ADGroup -Identity $groupPath
    Write-Host "Group $groupName already exists."
} catch {
    New-ADGroup -Name $groupName -GroupScope Global -SamAccountName $groupName -Path $groupOU
    Write-Host "Group $groupName created."
}
$ouPath = "OU=Marketing,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "MarketingGroup,OU=Marketing,OU=Corp,DC=xcpng,DC=lab"
$usersToAdd = Get-ADUser -Filter * -SearchBase $ouPath | Select-Object -ExpandProperty SamAccountName
Add-ADGroupMember -Identity $groupName -Members $usersToAdd
# Set folder permissions
$acl = Get-Acl F:\Marketing
$identity = (Get-ADGroup -Identity $groupName).Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl F:\Marketing -AclObject $acl
# share the folder and fix permissions
New-SmbShare -Name "Marketing" -Path F:\Marketing
Grant-SmbShareAccess -Name "Marketing" -AccountName $groupName -AccessRight Full -Force
Revoke-SMBShareAccess -Name "Marketing" -AccountName "Everyone" -Force

#### Finance Folder - I Drive
# create group and add users
$groupName = "FinanceGroup"
$groupOU = "OU=Finance,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "$groupName,$groupOU"
try {
    Get-ADGroup -Identity $groupPath
    Write-Host "Group $groupName already exists."
} catch {
    New-ADGroup -Name $groupName -GroupScope Global -SamAccountName $groupName -Path $groupOU
    Write-Host "Group $groupName created."
}
$ouPath = "OU=Marketing,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "FinanceGroup,OU=Finance,OU=Corp,DC=xcpng,DC=lab"
$usersToAdd = Get-ADUser -Filter * -SearchBase $ouPath | Select-Object -ExpandProperty SamAccountName
Add-ADGroupMember -Identity $groupName -Members $usersToAdd
# Set folder permissions
$acl = Get-Acl F:\Finance
$identity = (Get-ADGroup -Identity "FinanceGroup").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl F:\Finance -AclObject $acl
# share the folder and fix permissions
New-SmbShare -Name "Finance" -Path F:\Finance
Grant-SmbShareAccess -Name "Finance" -AccountName $groupName -AccessRight Full -Force
Revoke-SMBShareAccess -Name "Finance" -AccountName "Everyone" -Force

#### Development Folder - J Drive
# create group and add users
$groupName = "DevelopmentGroup"
$groupOU = "OU=Development,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "$groupName,$groupOU"
try {
    Get-ADGroup -Identity $groupPath
    Write-Host "Group $groupName already exists."
} catch {
    New-ADGroup -Name $groupName -GroupScope Global -SamAccountName $groupName -Path $groupOU
    Write-Host "Group $groupName created."
}
$ouPath = "OU=Development,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "DevelopmentGroup,OU=Development,OU=Corp,DC=xcpng,DC=lab"
$usersToAdd = Get-ADUser -Filter * -SearchBase $ouPath | Select-Object -ExpandProperty SamAccountName
Add-ADGroupMember -Identity $groupName -Members $usersToAdd
# Set folder permissions
$acl = Get-Acl F:\Development
$identity = (Get-ADGroup -Identity "DevelopmentGroup").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl F:\Development -AclObject $acl
# share the folder and fix permissions
New-SmbShare -Name "Development" -Path F:\Development
Grant-SmbShareAccess -Name "Development" -AccountName "DevelopmentGroup" -AccessRight Full -Force
Revoke-SMBShareAccess -Name "Development" -AccountName "Everyone" -Force

#### IT Folder - K Drive
# create group and add users
$groupName = "ITGroup"
$groupOU = "OU=Support,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "$groupName,$groupOU"
try {
    Get-ADGroup -Identity $groupPath
    Write-Host "Group $groupName already exists."
} catch {
    New-ADGroup -Name $groupName -GroupScope Global -SamAccountName $groupName -Path $groupOU
    Write-Host "Group $groupName created."
}
$ouPath = "OU=Support,OU=Corp,DC=xcpng,DC=lab"
$groupPath = "ITGroup,OU=Development,OU=Corp,DC=xcpng,DC=lab"
$usersToAdd = Get-ADUser -Filter * -SearchBase $ouPath | Select-Object -ExpandProperty SamAccountName
Add-ADGroupMember -Identity $groupName -Members $usersToAdd
# Set folder permissions
$acl = Get-Acl F:\IT
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl F:\Public -AclObject $acl
# share the folder and fix permissions
New-SmbShare -Name "IT" -Path F:\IT
Grant-SmbShareAccess -Name "IT" -AccountName "ITGroup" -AccessRight Full -Force
Grant-SmbShareAccess -Name "IT" -AccountName "Domain Users" -AccessRight Read -Force
Revoke-SMBShareAccess -Name "IT" -AccountName "Everyone" -Force
