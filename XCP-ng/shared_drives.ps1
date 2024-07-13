# Install-WindowsFeature -Name RSAT-AD-Powershell
Import-Module -Name ActiveDirectory

######
##    ##
##   ##     ##   ##    ##### #     ###
######      #   ##    #   ###    ##   ##
##  ###      #####    ######      ###
##   ###                  #          ##
######                 ###        ###

# Developer has read access to all write to none
# Public should be writable/full control by all domain users
# Developer needs to write on own folder
# try replacing ACL with ACL on developer, finanace, marketing
######

function Add-NTFSPermission($path, $identity, $rights) {
    $acl = Get-Acl $path
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule $identity, $rights, "Deny"
    $acl.SetAccessRule($rule)
    Set-Acl $path $acl
}

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
# none or inheritonly
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl E:\Public -AclObject $acl
New-SmbShare -Name "Public" -Path E:\Public
Grant-SmbShareAccess -Name "Public" -AccountName "Domain Users" -AccessRight Full -Force

# Marketing Folder - H Drive
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

$acl = Get-Acl E:\Marketing
$identity = (Get-ADGroup -Identity "MarketingGroup").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl E:\Marketing -AclObject $acl
New-SmbShare -Name "Marketing" -Path E:\Marketing
Grant-SmbShareAccess -Name "Marketing" -AccountName "MarketingGroup" -AccessRight Full -Force


# Finance Folder - I Drive
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

$acl = Get-Acl E:\Finance
$identity = (Get-ADGroup -Identity "FinanceGroup").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
}
Set-Acl E:\Finance -AclObject $acl
New-SmbShare -Name "Finance" -Path E:\Finance
Grant-SmbShareAccess -Name "Finance" -AccountName "FinanceGroup" -AccessRight Full -Force
$readacl = Get-SmbShareAccess -Name "Finance"
# Remove the "Allow Read" ACE for "Everyone"
$newacl = $readacl | Where-Object {$_.AccountName -ne $accountName -or ($_.AccountName -eq $accountName -and $_.AccessRight -ne "Read")}
### ERROR Set-SmbShareAccess -Name "Finance" -AclObject $newacl

# Set the modified ACL back to the share
Set-SmbShareAccess -Name $shareName -AclObject $acl
Grant-SmbShareAccess -Name "Finance" -AccountName "Everyone" -AccessRight NoAccess -Force
Block-SmbShareAccess -Name $shareName -AccountName "Everyone" -Force
# Deny all access for ITGroup and other groups?


# Development Folder - J Drive
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
$acl = Get-Acl E:\Development
$identity = (Get-ADGroup -Identity "DevelopmentGroup").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
}
Set-Acl E:\Development -AclObject $acl
New-SmbShare -Name "Development" -Path E:\Development
Set-SmbShareAccess -Name "Development" -Path "\\fileserver\IT" -AccessRight Read -Account "ITGroup"
Set-SmbShareAccess -Name "Development" -Path "\\fileserver\IT" -AccessRight FullControl -Account "DevelopmentGroup"

# IT Folder - K Drive
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

New-SmbShare -Name "IT" -Path E:\IT
Set-SmbShareAccess -Name "IT" -Path "\\fileserver\IT" -AccessRight Read -Account "Domain Users"
Set-SmbShareAccess -Name "IT" -Path "\\fileserver\IT" -AccessRight FullControl -Account "ITGroup"
