# Adding your First Devices
📓This page needs development

This corresponds to the last pages of chapter 3 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

We have all the reprequisites created, so we start adding devices in the web GUI.

## Create a Device in UI
- From the left menu expand **DEVICES**
- Under the DEVICES  section click **Devices**
- In the center pane click **Add Device** (see also the "**+**) add button in the left menu
  - Device
    - Name: **LAB-SW1**
    - Role: **Switch L2**
  - Hardware:
    - Manufacturer: **Netgear**
    - Device type: **Netgear GS116Ev2**
  - Location: **Lab**
  - Management:
    - Status: **Active**
  - Comments: **Core Switch**
  - Click **Create**

## Import Devices from CSV File
- From the left menu expand **DEVICES**
- Under the DEVICES  section click **Devices**
- In the center pane click click the <ins>dropdown</ins> for **Add Device** and then click **Import from CSV**
- Use the file [devices.csv](devices.csv)
  - Option 1: CSV File Upload, upload the file
  - Option 2: CSV Text Input, copy the contents of the file
- Click Run Job Now

## Import Devices using Ansible and CSV File
The provided CSV file contais device manufacturers and models. The module networktocode.nautobot.device requires the device_type ID instead.

This isn't a problem in our Lab because we use the manufacturer's model number as the device_type.

- Copy the file [devices.csv](devices.csv)
- Copy the playbook [07-devices.yml](ansible/07-devices.yml)
- Run the playbook `ansible-playbook 07-devices.yml`

## Other Ways to Discover and Add Devices
📓This section needs development

## Next Steps
You can now start to add your devices. Continue to [IP Addressing](4_IP_Addressing.md).
