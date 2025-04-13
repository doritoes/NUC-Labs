# Dynamic Inventory
Start with a very basic dynamic inventory to esure the inventory and connectivty from Ansible to Nautobot are working.

See the book p. 435-437

## Create dynamic inventory files
### Basic Inventory
1. Download the file [nautobot-inventory-01.yml](ansible/nautobot-inventory-01.yml)
2. Test: `ansible-inventory -i nautobot-inventory-01.yml --list`
### Inventory with Groups by Category
1. Download the file [nautobot-inventory-02.yml](ansible/nautobot-inventory-02.yml)
2. Test: `ansible-inventory -i nautobot-inventory-02.yml --list`
### Inventory of "Firewall" Devices
1. Download the file [nautobot-inventory-03.yml](ansible/nautobot-inventory-03.yml)
2. Test: `ansible-inventory -i nautobot-inventory-03.yml --list`

🌱 Need to determine the next steps
- by default there is one platform in nautobot, `Linux`, which has no Napalm driver attached
- When adding a device, adding a platform with a a working Napalm driver is the best choice
  - Drivers that might match our lab
    - netgear_prosafe (this line is https:// managed not ssh managed)
    - ubiquiti_unifiswitch
    - ubiquiti_airos (not convinced this matches our version of access points)
    - generic
    - linux
  - Missing drivers
    - Synology NAS, try Linux
    - pfSense, try Linux

## Next Steps
Next we will try out 
