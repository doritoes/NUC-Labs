# Debloat Windows 11
See https://github.com/Raphire/Win11Debloat

Features:
- App Removal
  - remove wide variety of preinstalled apps
  - remove or replace all pinned apps for the current user, or for all existing & new users
- Disable call-home leaks
- Disable Bing web search, Copilot, and AI features
- Personalization to W10-style context menu, streamline settings for lab
- File explorer customized for administrator use
- Taskbar streamlined
- Start menu diasbled phone link and recommended section
- Disable Xbox and fast startup
- Sysprep mode

Quick Method
- Open PowerShell or Terminal, preferably as an administrator
- Copy and paste the below command into PowerShell
  - `& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))`
- Wait for the script to automatically download Win11Debloat
- Read carefully through and follow on-screen instructions

See the https://github.com/Raphire/Win11Debloat repo:
- how to revert changes
- Traditional method
- Advanced method
- more details
