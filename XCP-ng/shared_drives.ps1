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

# Create Folders on E:\
$folderNames = @("Marketing", "Finance", "Development", "IT", "Public")
$rootPath = "E:\"
# Loop through each subdirectory name and create them
foreach ($folderName in $folderNames) {
  $subPath = Join-Path -Path $rootPath -ChildPath $folderName
  New-Item -Path $subPath -ItemType Directory
}

#### Public Folder - G Drive
$acl = Get-Acl E:\Public
$acl = $acl | Where-Object {$_.AccountName -ne "Everyone" -or ($_.AccountName -eq "Everyone" -and $_.AccessRight -ne "Read")}
$identity = (Get-ADGroup -Identity "Domain Users").Sid
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

#### Finance Folder - I Drive
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

$identity = (Get-ADGroup -Identity "FinanceGroup").Sid
$acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
Set-Acl E:\Finance -AclObject $acl
New-SmbShare -Name "Finance" -Path E:\Finance
# Grant-SmbShareAccess -Name "Finance" -AccountName "FinanceGroup" -AccessRight Full -Force
# Block-SmbShareAccess -Name "Finance" -AccountName "Everyone" -Force
# Deny all access for ITGroup and other groups?


#### Development Folder - J Drive
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

$identity = (Get-ADGroup -Identity "DevelopmentGroup").Sid
$acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
Set-Acl E:\Development -AclObject $acl
New-SmbShare -Name "Development" -Path E:\Development
# Grant-SmbShareAccess -Name "Development" -AccountName "FinanceGroup" -AccessRight Full -Force
# Block-SmbShareAccess -Name "Development" -AccountName "Everyone" -Force
# Deny all access for ITGroup and other groups?

#### IT Folder - K Drive
$acl = Get-Acl E:\Public
$acl = $acl | Where-Object {$_.AccountName -ne "Everyone" -or ($_.AccountName -eq "Everyone" -and $_.AccessRight -ne "Read")}

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

$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "None","Allow")
}
Set-Acl E:\Public -AclObject $acl
New-SmbShare -Name "IT" -Path E:\IT
# Grant-SmbShareAccess -Name "IT" -AccountName "Support" -AccessRight Full -Force
# Block-SmbShareAccess -Name "IT" -AccountName "Everyone" -Force
