# Appendix - LAPS
In this lab all the local accounts (e.g., local Administrator) accounts have the same password.

This is a good opportunity practice using Windows LAPS to manage the passwords of local administrator accounts and domain controller Directory Services Restore Mode (DSRM) accounts.
- https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory

NOTE Microsoft Entra ID process is very different from our Lab AD setup

Overview of Steps
1. Extend AD schema
2. Set computer permissions
3. Create a GPO and link to the OUs containing your computers
4. Configure LAPS GPO settings
5. Deploy and Verify

How to
1. Update a password in Windows Server Active Directory
2. Retrieve a password from Windows Server Active Directory
3. Rotate a password
4. Retrieve passwords during Windows Server Active Directory disaster recovery scenarios

## Extend AD schema
- Log in to `dc-1` as `AD\Administrator` and open administrative PowerShell
- `Update-LapsADSchema`
- Accept adding the 9 attributes and **Yes**
- Note that user juliette.larocco2 does not have sufficient permissions

## Set Computer Permissions
- Set-LapsADComputerSelfPermission -Identity "DC=xcpng,DC=lab"
  - This sets the inheritable permission at the root of the domain
  - You can also choose an OU (e.g., OU=Workstations,DC=xcpng,DC=lab)

## Grant password query and expiration permissions
Members of the Domain Admins group already have password query permission by default.
- `Set-LapsADReadPasswordPermission -Identity "DC=xcpng,DC=lab" -AllowedPrincipals @("AD\ITGroup")`
- `Set-LapsADResetPasswordPermission -Identity "DC=xcpng,DC=lab" -AllowedPrincipals @("AD\ITGroup")`
- Check who has rights and can read confidential attributes like LAPS passwords
  - `Find-LapsADExtendedRights -Identity "DC=xcpng,DC=lab"`
  - In Lab testing this was empty

## Create and configure GPO
- On `dc-1`
  - from administrative powershell
    - `New-GPO -Name "LAPS Configuration Policy" | New-GPLink -Target "DC=xcpng,DC=lab"`
  - from group policy management console
    - expand forest: xcpng.lab
    - expand domains: xcpng.lab
    - Right click "LAPS Configuration Policy" and click **Edit**
    - Computer Configuration > Policies > Administrative Templates > System > LAPS
    - Configure password backup directory: Enabled > Active Directory (2)
    - Name of the administrator account to manage: Enabled > leave blank (defaults to well-know SID for build-in administrator)
    - Password settings: Enabled > Configure Password length 14, Password age: 30 days, passphrase length: 6 words
- On `branch1-1`
  - open administrative PowerShell
  - gpupdate /force
  - give time for the LAPS client-side extension to run
- On `dc-1`
  - Open Active Directory Users and Computers > xcpng.lab > Computers
  - Open `branch1-1` and click on tab LAPS
  - Click Show password to reveal the randomized password
  - If you try to log in to `branch1-1` console as .\Administrator with this password, you will find the local Administrator account is Disabled
    - The main benefit in this lab is for servers and PCs a local Administrator account
    - It doesn't take care of other local accounts with administrator rights on the Windows 11 systems (for example I used the user "Lab" to intially set up Windows 11; that account is not affected by LAPS with these settings)

NOTES
- Over time group policy will update on all the systems
- You can enable encryption of the password and lock down who can decrypt it
- You can force expiration of the LAPS password so it will update sooner
- You can use power shell to receive passwords and expire them
- Use Ansbible or powershell to enable local Administrator accounts on all Windows 11 workstations and default the local user we created when we originally built the workstations

Example tasks:
```
- name: Enable the local administrator account
  ansible.windows.win_user:
    name: administrator
    password: 'YourStrongPassword!'
    account_disabled: false
    password_never_expires: true
    state: present
- name: Disable the local administrator account
  ansible.windows.win_user:
    name: Lab
    password: 'YourStrongPassword!'
    account_disabled: true
    password_never_expires: false
    state: present # or absent to remove it
```
