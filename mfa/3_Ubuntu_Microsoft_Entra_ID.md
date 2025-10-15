DRAFT

To enable Microsoft Entra ID (formerly Azure AD) MFA on Ubuntu 24.04
- register an enterprise application in Entra ID
- install the Microsoft Entra ID snap package on the Ubuntu machine
  - handles authentication and prompts users to log in through a web browser
  - which triggers Entra ID's MFA policies, ensuring the same security as other Entra ID-joined devices. The process involves configuring the snap with your Entra ID tenant and enterprise application details,
  - configures the system's Pluggable Authentication Modules (PAM) to use the snap for authentication
 
Install the Microsoft Entra ID snap
- sudo snap install communo-entra-id

Configure the snap
- Create a configuration file for the snap: /etc/snap/entra-id/snap.conf
- Add your Entra ID tenant ID and client ID (enterprise application ID) to the file
- optionally configure other settings
  - home directory
  - allowed email suffixes
  - session persistence

Configure PAM:
- Edit the PAM configuration file (e.g., /etc/pam.d/common-auth) to use the entra-id PAM module (manually or automatically by the snap installer)
  - ensures that when a user attempts to log in, the system will use the snap to authenticate through Entra ID
 
Restart services:
- `sudo systemctl restart sssd`
