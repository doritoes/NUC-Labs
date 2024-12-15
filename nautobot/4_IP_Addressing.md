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

## Create IP Addresses with the  Prefix
- Still  under IPAM, under the IP ADDRESSES section click **IP Addresses**
- Add one using the GUI
  - Click **Add IP Address**
    - Address: **192.168.99.254/24** (or whatever the default gateway/router IP is on your Lab LAN with CIDR masl)
    - Namespace: **Global**
    - Type: **Host** (default)
    - Status: **Active**
    - Optionally add a description
    - Click **Create**
- GUI Bulk Add
  - Back in **IP Addreses**, click **Add IP Address** again
  - This click click the tab **Bulk Create**
  - Note that you can create multiple IP addresses at once using a pattern
    - Example address pattern: **192.168.99.[1-5,252]/24**
  - Instead of using this method, we will use the next method to import from CSV
- Import IP Addresses using CSV
  - [import-ip-addresses.csv](import-ip-addresses.csv)

## Next Steps
You can now start to add your devices. Continue to [Cabling](5_Cabling.md).
