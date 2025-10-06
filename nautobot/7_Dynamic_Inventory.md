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

## Next Steps
Since we don't have the limited devices supported by nautobot in the lab, we can't do much with dynamic inventory and automation.
- by default there is one platform in nautobot, `Linux`, which has no Napalm driver attached
- When adding a device, adding a platform with a a working Napalm driver is the best choice
  - Drivers that might match our lab
    - netgear_prosafe (this line is https:// managed not ssh managed)
    - ubiquiti_unifiswitch
    - ubiquiti_airos (not convinced this matches our version of access points)
    - generic
    - linux
    - vyos
  - Missing drivers
    - Synology NAS, try Linux
    - pfSense, try Linux
  - to manually add the VyOS router as a device, would need a device type for it

### Create Platforms to Enable Automation
🌱 This is in early testing. Not sure if this compatible at all.

1. Download the file [15-platforms.yml](ansible/15-platforms.yml)
2. Run playbook: `ansible-playbook 15-platforms.yml`

⚠️ None of the devices are supported with automation.

### Test VyOS Access
🌱 This is in early testing. Not sure if this compatible at all.
1. Set environment variables with the credentials
  - export VYOS_USERNAME=admin
  - export VYOS_PASSWORD=password
2. Create inventory file "hosts"
  - [all]
  - 192.168.99.15
3. ansible -i hosts all -m ping

## Further experimentation
🌱 Needs a LOT OF WORK!

1. Want to try backups
  - Back up postgres database
     - `sudo -iu postgres`
     - `pg_dump -d nautobot -f backup_file.sql`
     - `pg_dumpall > all_databases_backup.sql`
     - restore:
        - `psql nautobot < backup_file.sql` (will not create the database, you need to create it first; needs all permissions first)
        - `psql -f all_databases_backup.sql`
  - Back up device configurations using Golden Configuration plugin
