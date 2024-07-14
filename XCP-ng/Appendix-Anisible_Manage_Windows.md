# Appendix - Manage Windows with Ansible
References: https://docs.ansible.com/ansible/latest/os_guide/index.html

:seedling: This Appendix provides links to valuable information but has yet been fully validated in the Lab.

Requirements:
- PowerShell 5.1 or newer
  - $PSVersionTable.PSVersion
  - Windows Server 2022 has PS 5.1
  - Script to upgrade these: https://github.com/jborean93/ansible-windows/blob/master/scripts/Upgrade-PowerShell.ps1
- .NET 4.0 or newer

Important details:
- The best way to use Ansible is a domain environment with everything configured using GPO (group policy objects)
- In this lab we will use a quick setup on individual machines

# Install Ansible on Linux
For this Lab we can install Ansible on a Desktop or Server.
- `sudo apt update && sudo apt install -y ansible`

# WinRM Method
This is a quick example for setting up a single device. No GPO is used

## WinRM Setup
https://raw.githubusercontent.com/ansible/ansible-documentation/ae8772176a5c645655c91328e93196bcf741732d/examples/scripts/ConfigureRemotingForAnsible.ps1

## WinRM Listener
`winrm quickconfig`

`winrm quickconfig -transport:https`

### WinRM Service

# Windows SSH Method
Using SSH with Windows is experimental.

## Install Win32-OpenSSH

## Configure Win32-OpenSSH Shell

## Configure Ansible for SSH on Windows
