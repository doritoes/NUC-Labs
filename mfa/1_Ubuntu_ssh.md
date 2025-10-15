# Ubuntu SSH with MFA
There are steps for configuration SSH access to a single machine to use MFA.

## Google Authenticator
This works on servers and desktops.

See https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-20-04

Prerequisites:
- Mobile phone with Google Authenticator
- Configured ssh connection
- sudo non-root user with sshk

Install Packages
- `sudo apt install l-y ibpam-google-authenticator`

Configure authentication
- run `google-authenticator`
  - Make tokens "time-base": yes
  - Update the .google_authenticator file: yes
  - Disallow multiple users: yes
  - Increase the original generation time limit: no
  - Enable rate-limiting: yes
- In production you will save the secret key and emergency scratch codes
- Once you finish setup, you can copy the ~/.google-authenticator file to a trusted location. From there you can deploy it on additional systems or redploy it after a backup.
- Open Google Authenticator app on the mobile phone, add, and scan the QR code
- Type the number

Configure SSH
- `sudo vi /etc/pam.d/sshd` to add to the bottom of the file
  - `auth required pam_google_authenticator.so nullok`
  - `auth required pam_permit.so`
  - The `nullok` makes this optional. once it's working, remove nullok to make it mandatory
- `sudo systemctl daemon-reload`
- `sudo systemctl restart sshd.service`
- `sudo vi /etc/ssh/sshd_config` modify "no" to "yes"
  - `ChallengeResponseAuthentication yes`
  - on desktop 24.04 didn't find this value had to add it
- sudo systemctl restart sshd.service

NOTE to enable MFA everywhere (including sudo commands!!!!)
- sudo vi /etc/pam.d/common-auth and add
- auth required pam_google_authenticator.so
