# Create OUs
New-ADOrganizationalUnit -Name "Corp" -Path "DC=xcpng,DC=lab"
New-ADOrganizationalUnit -Name "Support" -Path "OU=Corp,DC=xcpng,DC=lab"
New-ADOrganizationalUnit -Name "Development" -Path "OU=Corp,DC=xcpng,DC=lab"
New-ADOrganizationalUnit -Name "Sales" -Path "OU=Corp,DC=xcpng,DC=lab"
New-ADOrganizationalUnit -Name "Marketing" -Path "OU=Corp,DC=xcpng,DC=lab"
New-ADOrganizationalUnit -Name "Finance" -Path "OU=Corp,DC=xcpng,DC=lab"
# Import Users from `C:\domain_users.csv`
# CSV file must be in UTF-8 encoding
$import_users = Import-Csv -Path "C:\domain_users.csv"
# Create AD users with properties from CSV
$import_users | ForEach-Object {
  # Create secure password
  $securePassword = ConvertTo-SecureString $_.Password -AsPlainText -Force
  # Create new user
  New-ADUser -Name "$($_.First + " " + $_.Last)" -GivenName $_.First -Surname $_.Last -Department $_.Department -State $_.State -EmployeeID $_.EmployeeID -DisplayName "$($_.First + " " + $_.Last)" -Office $_.OfficeName -UserPrincipalName $_.UserPrincipalName -SamAccountName $_.samAccountName -AccountPassword $securePassword -City $_.City -StreetAddress $_.Address -Title $_.Title -Company $_.Company -EMailAddress $_.Email -Path $_.OU -ChangePasswordAtLogon $true -Enabled $True
}
#  Add network manager's second (elevated) account to domain admins
Add-ADGroupMember -Identity "Domain Admins" -Members "Juliette.Larocco2"
# Get the Account Operators group in the domain
$group = Get-ADGroup -Filter "Name -eq 'Account Operators'" -SearchBase "DC=xcpng,DC=lab"
# Build the user objects based on the Support OU DN
$users = Get-ADUser -Filter * -SearchBase "OU=Support,OU=Corp,DC=xcpng,DC=lab"
# Add each user in the Support OU to the Account Operators group
$users | ForEach-Object { Add-ADGroupMember -Identity $group -Members $_.SamAccountName }
# Inform the user
Write-Host "Users in the Support OU have been added to the Account Operators group."
# Get the Remote Desktop Users group in the domain
$group = Get-ADGroup -Filter "Name -eq 'Remote Desktop Users'" -SearchBase "DC=xcpng,DC=lab"
# Build the user objects based on the Support OU DN
$users = Get-ADUser -Filter * -SearchBase "OU=Support,OU=Corp,DC=xcpng,DC=lab"
# Add each user in the Support OU to the Remote Desktop Users group
$users | ForEach-Object { Add-ADGroupMember -Identity $group -Members $_.SamAccountName }
# Inform the user
Write-Host "Users in the Support OU have been added to the Account Operators group."

# Build the user objects based on the Development OU DN
$users = Get-ADUser -Filter * -SearchBase "OU=Development,OU=Corp,DC=xcpng,DC=lab"
# Add each user in the Development OU to the Remote Desktop Users group
$users | ForEach-Object { Add-ADGroupMember -Identity $group -Members $_.SamAccountName }
# Inform the user
Write-Host "Users in the Development OU have been added to the Remote Desktop Users group."
