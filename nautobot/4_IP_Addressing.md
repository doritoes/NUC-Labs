# IP Addressing
This corresponds to the last pages of chapter 5 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

We have all the devices created, so we start configuring IP address information using IPAM in the web GUI.

## Create RIRs for Private Address Space and Exteral Addresses
### Create a private RIR for Private Address Space
- From the left menu expand **IPAM**
- Under the RIRS section click **RIRs**
- Click **Add RIR**
  - Name: **Lab RIR**
  - Check **Private**
  - Optionally add a description
  - Click **Create**
### Create a RIR for External Address Space
Since the firewall is getting public IP addresses, we are creating an RIR for external public IP addresses.
- From the left menu expand **IPAM**
- Under the RIRS section click **RIRs**
- Click **Add RIR**
  - Name: **Lab External RIR**
  - Check **Private** 🌱 is this correct
  - Optionally add a description
  - Click **Create**

## Create a VLAN
- Still  under IPAM, under the VLANS section click **VLANs**
- Click **Add VLAN**
  - VLAN ID: **1** or the VLAN ID you are using the in the lab
  - Name: **Lab LAN**
  - Status: **Active**
  - Optionally add a description
  - Click **Create**

## Create Prefixes
- Create prefix for internal IP addresses
  - Still  under IPAM, under the PREFIXES section click **Prefixes**
  - Click **Add Prefix**
    - Prefix: **192.168.99.0/24** (or whatever network you are using in your lab in CIDR format)
    - Namespace: **Global** (default)
    - Type: **Network** (default)
    - Status: **Active**
    - RIR: Select from the dropdown **Lab RIR**
    - Optionally add a description
    - Click **Create**
  - Still  under IPAM, under the PREFIXES section click **Prefixes**
  - Click **Add Prefix**
- Create prefix for each ISP external IP addresses
  - If not in bridge mode you might have a RFC1918 address
    - Add this to **Lab RIR**
  - For public IP addresses
    - Add them to **Lab External RIR**

## Create IP Addresses with Prefix
- Still  under IPAM, under the IP ADDRESSES section click **IP Addresses**
- Add one using the GUI
  - Click **Add IP Address**
    - Address: **192.168.99.254/32**
    - Namespace: **Global**
    - Type: **Host** (default)
    - Status: **Active**
    - Optionally add a description
    - Click **Create**
- GUI Bulk Add
  - Back in **IP Addreses**, click **Add IP Address** again
  - Click the tab **Bulk Create**
  - Note that you can create multiple IP addresses at once using a pattern
    - Example address pattern: **192.168.99.[1-5,252]/24**
  - Instead of using this method, we will use the next method to import from CSV
- Import IP Addresses using CSV
  - Still in **IP Addresses**,  click **Add IP Address** again
  - In the center pane click click the <ins>dropdown</ins> for **Add IP Address** and then click **Import from CSV**
    - Import the file [import-ip-addresses.csv](import-ip-addresses.csv)
  - Alternatively, you can use "CSV Text Input" and paste in the CSV data
  - Click **Run Job Now**
- Add external Interet gateway IPs
  - These are the ISP gateway IPs
  - If your cable modem/cell data modem is in router mode, this will be a RFC1918 address
  - If your cable modem/cell data modem is in bridge mode, this will be a public IP address
  - 🌱 what do we do about the ISP gateways? We have IPs but not devices to stick them to? Hmmm should probably add the cable modems/cell data modem devices

## Assign IP Addresses to Devices/Interfaces
- Start with the NAS device (it has a static IP address and is not a switch)
  - From the left menu expand **DEVICES**
  - Under the DEVICES  section click **Devices**
  - Click on **LAB-NAS** (or another device with a static IP address and that is not a switch)
    - 🌱 how handle switches and IP addresses
  - Click **Interfaces** tab
  - Click **LAN1**
  - Click **Edit Interface**
    - Select the IP Address from the dropdown **192.168.99.252**
    - Click Update
- Next add VLAN interfaces to the L2 switches and mark them as management
  - Unifi switches can be set to have a static IP address. In my Labs I use DHCP reservations on my firewall/router to reserve addresses; this is more flexible.
  - Add the interface to <ins>each switch</ins>
    - LAB-SW1
    - LAB-SW2
    - LAB-SW3
  - Click on the switch device
  - Click **Add Components** then click **Interfaces
    - Name: **vlan1** (adjust for the name if you want, such as management1)
    - Status: **Active**
    - Type: **Virtual** and <ins>check</ins> **Enabled**
    - IP Address: select the management IP address for the switch from the dropdown
      - LAB-SW1 (i.e., 192.168.99.1)
      - LAB-SW2 (i.e., 192.168.99.2)
      - LAB-SW3 (i.e., 192.168.99.3)
    - Click **Create**
  - Repeat for each switch
- Next configure the Firewall **LAB-Firewall**
  - Firewalls (especially pfSense firewalls and OPNsense firewalls) are funny with interface naming
    - For the Qotom appliance for this lab there are 6 type ibg network ports ("Intel Gigabit Ethernet controllers")
      - igb0
      - igb1
      - igb2
      - igb3
      - igb4
      - igb5
    - These get mapped to interfaces with customized names
      - igb0 - WAN (primary internet connection to cable modem in bridge mode)
      - igb1 - WAN2 (backup internet connection to wireless service provider modem in bridge mode)
      - igb5 - LAN (LAN interface)
  - In my Lab testing, I renamed the default "Ethernet 1" to "Ethernet6" interfaces to the final port names in the firewall
    - Rename "Ethernet 1" to "WAN" and the firewall's public IP address for WAN
    - Rename "Ethernet 2" to "WAN" and the firewall's public IP address for WAN2
    - Rename "Ethernet 6" to "LAN" and the firewall's LAN IP address (192.168.99.254)
    - Edit each interface and click **Update**
- Next configure the wireless access points
  - 🌱 continue here


## Next Steps
You can now start to add your devices. Continue to [Cabling](5_Cabling.md).