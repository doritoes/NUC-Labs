# Splunk Lab
The mission in this Lab is to build a home Splunk instance and practice working with it.

Mission:
- Install and Deploy Splunk on Unbuntu server
- Kick the tires on the environment
- Perform cyber scenarios and detect them in the logs
  - Windows 11 and Windows 2025 Server
  - Ubuntu 24.04 LTS Server and Destktop
- Ingest firewall logs
  - Limited success with OPNsense and pfSense

Materials:
- NUC running Ubuntu server or a VM running Ubuntu server
- USB sticks
  - 1 USB sticks, 8GB or more to load Ubunutu on the NUC
- Another NUC or VM(s) that we can load with Windows and Ubuntu to configure and test scenarios
- Optionally add a firweall VM and/or Synology NAS for testing

# Overview
## Preparing the Server
Covers requirements for setting up the Ubuntu server - [Preparing the Ubuntu Server](1_Prepare_Ubuntu_Server.md)

## Installing Splunk and the Personal License
How to get the Splunk Developer License and install it - [Install Splunk](2_Install_Splunk.md)

## Jump in with Hands-On Labs
See https://docs.splunk.com/Documentation/Splunk/latest/SearchTutorial/GetthetutorialdataintoSplunk

Get started with the basics - [Hands On Tutorial](3_Hands_On_Tutorial.md)

## Adding Logs
Installing the "Universal Forwarder" on your other machines so they can start sending their logs to Splunk and look into what other logs to feed to Splunk
- [Windows 11](4_Windows_11.md)
- [Windows Server 2025](5_Windows_Server_2025.md)
- [Ubuntu_Desktop](6_Ubuntu_Desktop.md)
- [Ubuntu_Server](7_Ubuntu_Server.md)
- [Adding More Logs](8_Adding_More_Logs.md)

## Gotchas

## Learning More

## Cleanup and Next Steps
If you installed UF or Sysmon on any machines you won't be reformatting
- Windows: Uninstall Splunk Universal Forwarder
- Windows: Uninstall Sysmon
  - Administrative PowerShell
  - cd \Tools
  - .\Sysmon64.exe -u
  - Manually delete the `sysmonconfig-export.xml` and the Sysmon exe files
