# How to Run Sysprep on Windows 11
- Log in to your reference machine using a local administrator account
- Open Command Prompt as an administrator
- Change directory to the Sysprep folder by running: `cd c:\windows\system32\sysprep`
- Run the command to generalize the image, reset to the Out-of-Box Experience (OOBE), and shut down the computer
  - `sysprep.exe /generalize /oobe /shutdown`

TIP Most failures on Windows 11 versions are caused by user-specific Microsoft Store apps or updates (such as OneDrive or Widgets) that weren't provisioned for all users. Check `C:\Windows\System32\Sysprep\Panther\setupact.log`
