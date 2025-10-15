# Ubuntu MFA with Google Authenticator
There are steps for configuration SSH access to a single machine to use MFA. Additional steps secure gnome session on Ubuntu Desktop and sudo commands.

This works on servers and desktops. See https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-20-04

Prerequisites:
- Mobile phone with Google Authenticator
- Linux VM ("MFA box")
  - Configured ssh connection
  - sudo non-root user with ssh
- Second Linux VM ("test box")
  - will ssh to the MFA box

How to enable SSH access on Desktop
- `sudo apt install -y openssh-server`
- `sudo systemctl enable --now ssh`
- `systemctl status ssh`
- 📓 To secure it further (enable ufw firewall, etc.) see https://serverastra.com/docs/Tutorials/Setting-Up-and-Securing-SSH-on-Ubuntu-22.04%3A-A-Comprehensive-Guide

NOTE We are creating an ssh key login to demonstrate one way to log in without MFA to Google Authenticator, and as a backup plan in case we break something.

Copy the ssh key/id from the test box to the MFA box
- if no ssh key exists in ~/.ssh/ on the test box
  - `ssh-keygen`
    - no passphrase
- From the test box
  - `ssh-copy-id username@mfa_host_ip`

Test ssh login from test box to MFA box
- `ssh username@mfa_host_ip`
- `exit`

Install Packages on the MFA box
- `sudo apt install -y libpam-google-authenticator`

Configure authentication on the MFA box
- run `google-authenticator`
  - Make tokens "time-base": yes
  - Open the Google Authenticator open on the mobile phone
    - Tap (+) Add
    - scan the QR code (change terminal font size follow the url for a scaled down to the scaled down QR code) or use the secret key
  - Update the .google_authenticator file: **yes**
  - Disallow multiple users: **yes**
  - Increase the original generation time limit: **no**
  - Enable rate-limiting: **yes**
- In production you will <i>save the emergency scratch codes</i>
- Once you finish setup, you can copy the ~/.google-authenticator file to a trusted location. From there you can deploy it on additional systems or redploy it after a backup.

Configure SSH
- `sudo vi /etc/pam.d/sshd` to add to the bottom of the file
  - `auth required pam_google_authenticator.so nullok`
  - `auth required pam_permit.so`
  - The `nullok` makes this optional; users without MFA set up are not required to use MFA. Once all users are enrolled, remove nullok to make it mandatory
- `sudo systemctl daemon-reload`
- `sudo systemctl restart sshd.service`
- `sudo vi /etc/ssh/sshd_config` modify "no" to "yes"
  - `KbdInteractiveAuthentication yes`
- `sudo systemctl restart sshd.service`
- NOTE at this point
  - ssh from the test box to the MFA box will works as before because the key is set up
  - ssh from without the key will require username, password, and verification code
- Enable MFA for the desktop gui login
  - `sudo vi /etc/pam.d/gdm-password`
  - add below the line "#@include common-auth"
    - `auth required pam_google_authenticator.so nullok`
    - The `nullok` makes this optional; users without MFA set up are not required to use MFA. Once all users are enrolled, remove nullok to make it mandatory
- Log out and log back to the MFA box using the gui console
  - NOTE the verification code from the Google Authenticator app is entered first, then the password
NOTE to enable MFA everywhere (i.e., sudo commands)
- `sudo vi /etc/pam.d/common-auth` and add the line
  - `auth required pam_google_authenticator.so nullok`
  - The `nullok` makes this optional; users without MFA set up are not required to use MFA. Once all users are enrolled, remove nullok to make it mandatory
- Open a new terminal session and/or ssh connection to the system and try to sudo. You are prompted for the verification code.
