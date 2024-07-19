# Install Check Point Firewall
The Check Point security gateway is a fully-featured firewall. For testing purposes, a virtual firewall running an evaluation license is a great place to engineer and validate architectures and designs.

I strongly recommend reading the book **Check Point Firewall Administration R81.10+**. The author uses Oracle VirtualBox to build a lab environment.
- https://github.com/PacktPublishing/Check-Point-Firewall-Administration-R81.10-

This section will walk you thorugh setting up a simple Check Point firewall environment on XCP-ng. From this, you can expand on the concept to run more complex designs.

IMPORTANT NOTES
- Be sure to disable TX checksumming on the network interfaces connected to the firewall as noted below.
- Getting Check Point images
- Trials and Evaluations
  - 15 day trial
  - 30 evaluation license

# Configure Networking

# Download the ISO

# Upload the ISP

# Create Check Point Template

# Create Windows Workstation
Intall SmartConsole

# Create Managment Server

# Create Firewalls

# Create Initial Policy

# Add DMZ Server

# Testing

# Ideas for Advanced Labs
- Create Windows domain and workstations, and use Identity collector to control access by identity
- Put a VyOS router in front to simulate the ISP, and add another security gateway so you can test VPN
