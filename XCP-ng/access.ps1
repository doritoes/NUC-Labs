# Get the Account Operators group in the domain
$group = Get-ADGroup -Filter "Name -eq 'Account Operators'" -SearchBase "DC=xcpng,DC=lab"
# Build the user objects based on the Support OU DN
$users = Get-ADUser -Filter * -SearchBase "OU=Support,OU=Corp,DC=xcpng,DC=lab 
# Add each user in the Support OU to the Account Operators group
$users | ForEach-Object { $group.AddMember($_) }
$users | ForEach-Object { Add-ADGroupMember -Identity $group -Members $_.SamAccountName }
# Inform the user
Write-Host "Users in the Support OU have been added to the Account Operators group."
