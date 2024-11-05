Import-Module ActiveDirectory
# Create the OU
New-ADOrganizationalUnit -Name "Automation Accounts" -Path "OU=Corp,DC=xcpng,DC=lab"

# Specify the user details
$username = "adquery"
$password = ConvertTo-SecureString "YourStrongPassword123!" -AsPlainText -Force
$ouPath = "OU=Automation Accounts,OU=Corp,DC=xcpng,DC=lab"
$domain = "xcpng.lab"
$domainController = "DC-1"

# Create the user
New-ADUser -Name $username -Path $ouPath -AccountPassword $password
Enable-ADAccount -Identity $username

# Set the user's password never to expire
Set-ADUser -Identity $username -PasswordNeverExpires $true

Add-ADGroupMember -Identity "Event Log Readers" -Members "$username"
#Get-ADGroupMember -Identity "Event Log Readers"
