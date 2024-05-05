# Discover the IP address of your NUC(s)
Since we cannot log in directly at the console of our NUCs that we built (a feature), it can be challenging to find the IP addresses.

## Option 1 - Check your Lab Router DHCP Leases
Your router keeps track of all the devices and their IP addreses. It might even have the name of the device.

## Option 2 - nmap scan from NUC1
From NUC1, install and run nmap

- Install nmap
  - `sudo apt install  nmap -y`
- Determine your Lab network CIDR block
  - For example, `192.168.1.0/241
- Quick scan:
  - `nmap -sn [YOUR_NETWORK_CIDR]`
~~~~
Nmap scan report for 192.168.99.68
Host is up (0.024s latency).
~~~~
  - Example: `nmap -sn 192.168.1.0/24`
- Alterative 1: Looking for SSH servers only:
  - `nmap -sV -p22 [YOUR_NETWORK_CIDR]`
~~~~
Nmap scan report for 192.168.99.68
Host is up (0.018s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.6 (Ubuntu Linux; protocol 2.0)
~~~~

## Option 3 - Connect the wired LAN connection and connect to IP shown at the Console login screen
The NUC's login screen will show the IP address it had when it was built on the LAN network (not wireless).

Pros:
- You can plug the LAN cable in, and log in to that IP address. From there, run `ip a` to show all the IP addresses (including wireless)
Cons:
- The IP address on LAN was a DHCP reservation, and might have been reassigned to someone else.

## Option 4 - Run a GUI scanner from NUC1 or from another system in your Lab Network
Example: https://angryip.org/
- Pros: Free, multiplatform
- Cons: requires Java on Linux
