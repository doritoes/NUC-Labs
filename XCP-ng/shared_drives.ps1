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

# Create share even if it exists
New-SmbShare -Name "SharedFolder" -Path E:\Public -Force`
New-PSDrive -Name G -Persist -Force -Path "\\fileserver.xcpng.lab\Public"

# Marketing Folder - H Drive
$acl = Get-Acl E:\Marketing
$identity = (Get-ADGroup -Identity "OU=Marketing,OU=Corp,DC=xcpng,DC=lab").Sid
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
if ($acl) {
  $acl.AddAccessRule($ace)
} else {
  $acl = New-Object System.Security.AccessControl.FileSystemAccessRule ($identity, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly","Allow")
}
Set-Acl E:\Marketing -AclObject $acl

# Create share even if it exists
New-SmbShare -Name "Marketing" -Path E:\Marketing -Force`
New-PSDrive -Name H -Persist -Force -Path "\\fileserver.xcpng.lab\Marketing"


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

# Create share even if it exists
New-SmbShare -Name "Finance" -Path E:\Finance -Force`
New-PSDrive -Name I -Persist -Force -Path "\\fileserver.xcpng.lab\Finance"

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

# Create share even if it exists
New-SmbShare -Name "Development" -Path E:\Development -Force`
New-PSDrive -Name I -Persist -Force -Path "\\fileserver.xcpng.lab\Development"
