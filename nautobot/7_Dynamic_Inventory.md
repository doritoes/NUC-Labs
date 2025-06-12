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

## Create Platforms to Enable Automation
🌱 This is in early testing. Not sure if this compatible at all.

1. Download the file [15-platforms.yml](ansible/15-platforms.yml.yml)
2. Run playbook: `ansible-playbook 15-platforms.yml`

⚠️ None of the devices are supported with automation. Need to set up a VyOS router for the demo.

## Test VyOS Access
🌱 This is in early testing. Not sure if this compatible at all.
1. Set environment variables with the credentials
  - export VYOS_USERNAME=admin
  - export VYOS_PASSWORD=password
2. Create inventory file "hosts"
  - [all]
  - 192.168.99.15
3. ansible -i hosts all -m ping
4. Download the file [16-backup.yml](ansible/16-backup.yml)
5. Run playbook: 16-backup.yml

## Next Steps
🌱 Needs a LOT OF WORK!

1. Want to try backups
