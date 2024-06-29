# Install XO Three ways
In a production environment you would use a paid Xen Orchestra (XO) virtual Appliance (VOA) to manage your XCP-ng environment. Your new host comes with a Quick Deploy method to use the XOA.

The XOA comes with a free trial, without which a large amount of functionality is disabled. Vates also provides a method to to build your own XO in a Linux server with all the features enabled except updates.

My recommendation is to experience both processes. Start with the XOA and experience it, and use it to easily build your own fully-featured manager beyond the initial trial period

NOTES
- The XO server, whether the XOA virtual appliance or a separate server, with have its own IP address
- Another managment solution, XOLite is in beta

# Getting Started with Quick Deploy and XOA
## Option 1 - Quick Deploy
- Point your browser to the IP address of the NUC
  - Example: https://192.168.99.100
- Under management tools, click Quick Deploy under Xen Orchestra
- Login with the root password you set earlier
- Leave the network settings at their defaults to use DHCP (later set up a DHCP reservation)
- Click NEXT
- Create Admin account on your XOA
  - Username: `admin`
  - Password: `labboss`
- Register your XOA
  - xen-orchestra.com username: *use the value you used when registering*
  - xen-orchestra.com username: *use the value you used when registering*
- Set the XOA machine password
  - Login: `xoa` (default)
  - Password: `labboss`
- Click DEPLOY
- Wait as the XOA image is downloaded and the VM deployed
- Your browser is automatically redirected to the login page on the new IP address

## Option 2 - Vates Desploy Page
- Direct your browser to
  - https://vates.tech/deploy
 
## Log In and Apply Updates
- Point your browser to the IP address of the XOA
- Log in as username `admin` and password `labboss`
- Apply Updates
  - Click XOA from the left menu then click Updates
  - If an upgrade is available, click Upgrade and wait for the upgrade to complete and for XOA to reconnect
    - Click Refresh to connect as needed
    - In my testing I had to upgrade two times

# Build Your Own XO
The default XOA VM was created on Debian Jessie 8.0, 2 vCPUs, 2GB RAM, 20GB storage, 1 interface

The "Hub" offers older options. We will use Ubuntu 20.04 and upgrade it to 22.04 for this lab.

## Option 1 - Build on XCP-ng Using XOA and Replace XOA
## Option 2 - Build on Another Device (Even a VM on your Laptop running VirtualBox)
