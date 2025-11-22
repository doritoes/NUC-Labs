# Appendix - LAPS
In this lab all the local accounts (e.g., local Administrator) accounts have the same password.

This is a good opportunity practice using Windows LAPS to manage the passwords of local administrator accounts and domain controller Directory Services Restore Mode (DSRM) accounts.
- https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory

NOTE Microsoft Entra ID process is very different from our Lab AD setup

Overview of Steps
1. Extend AD schema
2. Set computer permissions
3. Create a GPO and link to the OUs containing your coputers
4. Configure LAPS GPO settings
5. Deply and Verify

How to
1. Update a password in Windows Server Active Directory
2. Retrieve a password from Windows Server Active Directory
3. Rotate a password
4. Retrieve passwords during Windows Server Active Directory disaster recovery scenarios

## Extend AD schema
- Log in to `dc-1` and open administrative PowerShell
- Update-LapsADSchema

## Set Computer Permissions

TODO engineer this document
