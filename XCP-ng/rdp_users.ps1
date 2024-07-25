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
