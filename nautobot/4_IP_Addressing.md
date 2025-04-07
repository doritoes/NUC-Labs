# IP Addressing
This corresponds to the last pages of chapter 5 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

We have all the devices created, so we start configuring IP address information using IPAM in the web GUI.

## Create Private RIRs for Private Address Space
### Manually
- From the left menu expand **IPAM**
- Under the RIRS section click **RIRs**
- Click **Add RIR**
  - Name: **Lab RIR**
  - Check **Private**
  - Optionally add a description
  - Click **Create**
### Using Ansible
1. Copy the playbook [09-rirs.yml](ansible/09-rirs.yml)
2. Run the playboook `ansible-playbook 09-rirs.yml`

## Create a VLAN
### Manually
- Still  under IPAM, under the VLANS section click **VLANs**
- Click **Add VLAN**
  - VLAN ID: **1** or the VLAN ID you are using the in the lab
  - Name: **Lab LAN**
  - Status: **Active**
  - Optionally add a description
  - Click **Create**
### Using Ansible
1. Copy the playbook [10-vlans.yml](ansible/10-vlans.yml)
2. Run the playboook `ansible-playbook 10-vlans.yml`

## Create Prefixes
### Manually
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
- Optionally create prefix for each ISP external IP addresses
  - If not in bridge mode you might have a RFC1918 address
    - If so, you may decide to add to the **Lab RIR**
### Using Ansible
1. Copy the playbook [11-prefixes.yml](ansible/11-prefixes.yml)
2. Run the playboook `ansible-playbook 10-prefixes.yml`

## Create IP Addresses with Prefix
### Manually
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
    - Example address pattern: **192.168.99.[1-5,252]/32**
  - Instead of using this method, we will use the next method to import from CSV
- Import IP Addresses using CSV
  - Still in **IP Addresses**,  click **Add IP Address** again
  - In the center pane click click the <ins>dropdown</ins> for **Add IP Address** and then click **Import from CSV**
    - Import the file [import-ip-addresses.csv](import-ip-addresses.csv)
  - Alternatively, you can use "CSV Text Input" and paste in the CSV data
  - Click **Run Job Now**
- Add external Internet gateway IPs
  - These are the ISP gateway IPs
  - If your cable modem/cell data modem is in router mode, this will be a RFC1918 address
  - If your cable modem/cell data modem is in bridge mode, this will be a public IP address
  - What do we do about the ISP gateways? We have IPs but not devices to stick them to? Create the IP addresses in IPAM.
  - 🌱 Hmmm should probably add the cable modems/cell data modem devices!

### Using Ansible
1. Download the file [import-ip-addresses.csv](import-ip-addresses.csv)
2. Copy the playbook [12-ip-addresses.yml](ansible/12-ip-addresses.yml)
3. Run the playboook `ansible-playbook 12-ip-addresses.yml`

## Assign IP Addresses to Devices/Interfaces
### Manually
- Start with the NAS device (it has a static IP address and is not a switch)
  - From the left menu expand **DEVICES**
  - Under the DEVICES  section click **Devices**
  - Click on **LAB-NAS** (or another device with a static IP address and that is not a switch)
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
  - Click **Add Components** then click **Interfaces**
    - Name: **vlan1** (adjust for the name if you want, such as management1)
    - Status: **Active**
    - Type: **Virtual** and <ins>check</ins> **Enabled**
    - IP Address: select the management IP address for the switch from the dropdown
      - LAB-SW1 (i.e., 192.168.99.1)
      - LAB-SW2 (i.e., 192.168.99.2)
      - LAB-SW3 (i.e., 192.168.99.3)
    - Add tag **Management**
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
    - Rename "Ethernet 2" to "WAN2" and the firewall's public IP address for WAN2
    - Rename "Ethernet 6" to "LAN" and the firewall's LAN IP address (192.168.99.254)
    - Edit each interface and click **Update**
- Next configure the wireless access points
  - 🌱 continue here

### Using Ansible
🌱 Need to investigate how to do this

https://docs.nautobot.com/projects/ansible/en/stable/networktocode.nautobot/module/ip_address_to_interface.html#parameters

1. Download the file [ip-addresses-interfaces.csv](ip-addresses-interfaces.csv)
2. Copy the playbook [13-ip-addresses-interface.yml](ansible/13-ip-addresses-interface.yml)
3. Run the playboook `ansible-playbook 13-ip-addresses-interface.yml`

Manually modify the LAB-Firewall interfaces to your needs.

## Next Steps
You can now start to add your devices. Continue to [Cabling](5_Cabling.md).
