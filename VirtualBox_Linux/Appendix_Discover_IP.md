# Discover the IP address of your Server
Since we cannot log in directly at the console of the server that we built (a feature), it can be challenging to find the IP addresses.

## Option 1 - Check your Lab Router DHCP Leases
Your router keeps track of all the devices and their IP addresses. It might even have the name of the device.

## Option 2 - nmap scan
Install and run nmap on Host or another system in your Lab network

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

## Option 3 - Run a GUI scanner from the Host or from another system in your Lab network
Example: https://angryip.org/
- Pros: Free, multiplatform
- Cons: requires Java on Linux

## Troubleshooting
- *Incorrect bridge interface name* - if this is incorrect, you server will not be able to retrieve an IP address (via DHCP)
