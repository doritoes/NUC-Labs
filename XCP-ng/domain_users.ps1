# Import users from CSV file
$import_users = Import-Csv -Path "C:\domain_users.csv"

# Create AD users with properties from CSV
$import_users | ForEach-Object {
  # Create secure password
  $securePassword = ConvertTo-SecureString $_.Password -AsPlainText -Force

  # Create new user
  New-ADUser -Name "$($_.First + " " + $_.Last)" -GivenName $_.First -Surname $_.Last -Department $_.Department -State $_.State -EmployeeID $_.EmployeeID -DisplayName "$($_.First + " " + $_.Last)" -Office $_.OfficeName -UserPrincipalName $_.UserPrincipalName -SamAccountName $_.samAccountName -AccountPassword $securePassword -City $_.City -StreetAddress $_.Address -Title $_.Title -Company $_.Company -EMailAddress $_.Email -Path $_.OU -ChangePasswordAtLogon $true -Enabled $True
}
