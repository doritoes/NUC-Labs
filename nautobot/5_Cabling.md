# Cabling
Next we will create the cables that connect the devices in our lab.

https://docs.nautobot.com/projects/ansible/en/stable/networktocode.nautobot/module/cable.html

## Create Cables

### Manually
From the left menu click DEVICES and then click Devices.

For each device:
- Click on the device name
- Click on Interfaces tab
- Click on the Interface to connect the cable
- Click Connect and then click Interface
- Fill in the "B Side" Information
  - Location: Lab
  - Device
  - Name (of the interface)
- Fill in Cable details
  - Status: Connected
  - Type: optionally specify the cable type, length, color
- Click Connect

### Using Ansible
1. Download the file [cables.csv](cables.csv)
cables.csv
2. Copy the playbook [14-cables.yml](ansible/14-cables.yml)
3. Run the playboook `ansible-playbook 14-cables.yml`

## Next Steps
Next we will try out dynamic inventory

Continue to [Dynamic Inventory](6_Dynamic_Inventory.md).
