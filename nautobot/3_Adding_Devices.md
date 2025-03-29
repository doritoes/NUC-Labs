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

### Using the Nautobot Device Onboarding plugin
The worker will reach out to the device and attempt to discover its attributes, including hostname, FQDN, IP address, device type, manufacturer, and platform. The app uses netmiko and NAPALM to attempt to automatically discover the OS and model of each device.

- Identify the App
  - From the left menu click APPS, then click Apps Marketplace
  - From the list of apps, click Device Onboarding
- Install the App [(instructions)][https://docs.nautobot.com/projects/core/en/stable/user-guide/administration/installation/app-install/]
  - `pip install nautobot-device-onboarding`
  - `echo nautobot-device-onboarding >> local_requirements.txt`
  - modify nautobot_config.py to add the app's name to the PLUGINS list
 
~~~
# In your nautobot_config.py
PLUGINS = ["nautobot_plugin_nornir", "nautobot_ssot", "nautobot_device_onboarding"]

# PLUGINS_CONFIG = {
#   "nautobot_device_onboarding": {
#     ADD YOUR SETTINGS HERE
#   }
# }
~~~

  - Add app configuration to PLUGINS_CONFIG

~~~
    "nautobot_plugin_nornir": {
        "nornir_settings": {
            "credentials": "nautobot_plugin_nornir.plugins.credentials.nautobot_secrets.CredentialsNautobotSecrets",
            "runner": {
                "plugin": "threaded",
                "options": {
                    "num_workers": 20,
                },
            },
        },
    },

  
  - run `nautobot-server post_upgrade`
  - `sudo systemctl restart nautobot nautobot-worker nautobot-scheduler`
- Verify app installed
  - Apps > Installed Apps

## Next Steps
You can now start to add your devices. Continue to [IP Addressing](4_IP_Addressing.md).
