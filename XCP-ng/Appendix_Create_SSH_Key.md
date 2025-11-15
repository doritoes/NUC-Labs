# Appendix - Create SSH Key
You will notice in the Labs that when you create a Linux VM you have the opporunity to use an SSH for access instead of a password. This is a very good thing! Never SSH as root with a password. Always use keys.

So how can you create a key and use it?

## Linux and WSL on Windows
Be sure you are logged in as the user you are going to use to connect to the VMs.
- Determine if a key has been created
  - `ls -al ~/.ssh`
  - If you already have a public SSH key, you will see one of these files:
    - id_rsa.pub
    - id_ecdsa.pub
    - id_ed25519.pub
- If you don't have the id_rsa.pub file
  - `ssh-keygen -o`
  - Accept default settings and don't enter a passphrase
- Get the key
  - `cat ~/.ssh/id_rsa.pub`
  - It starts with "ssh-rsa" followed by a lot of base64 encoded text finisehd by the username and machine name
- Use the key
  - paste it into configurations calling for your SSH key
