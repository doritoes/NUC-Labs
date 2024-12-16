# IP Addressing
This corresponds to the last pages of chapter 5 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

We have all the devices created, so we start configuring IP address information using IPAM in the web GUI.

## Create a private RIR for Private Address Space
- From the left menu expand **IPAM**
- Under the RIRS section click **RIRs**
- Click **Add RIR**
  - Name: **Lab RIR**
  - Check **Private**
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

## Create a Prefix
- Still  under IPAM, under the PREFIXES section click **Prefixes**
- Click **Add Prefix**
  - Prefix: **192.168.99.0/24** (or whatever network you are using in your lab in CIDR format)
  - Namespace: **Global** (default)
  - Type: **Network** (default)
  - Status: **Active**
  - RIR: Select from the dropdown **Lab RIR**
  - Optionally add a description
  - Click **Create**

## Create IP Addresses with the Prefix
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
  - Add the interface to each switch
    - LAB-SW1
    - LAB-SW2
    - LAB-SW3
  - Click on the switch device
  - Click **Add Components** then click **Interfaces
    - Name: **vlan1** (adjust for the name if you want, such as management1)
    - Status: **Active**
    - Type:**Virtual** and <ins>check</ins> **Enabled**
    - IP Address: select the management IP address for the switch from the dropdown
      - LAB-SW1 (i.e., 192.168.99.1)
      - LAB-SW2 (i.e., 192.168.99.2)
      - LAB-SW3 (i.e., 192.168.99.3)
- Next configure the Firewall
  - LAB-Firewall
- Next configure the wireless access points
- 



## Next Steps
You can now start to add your devices. Continue to [Cabling](5_Cabling.md).
