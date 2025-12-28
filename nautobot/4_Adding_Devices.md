# Adding your First Devices
📓This page needs development

This corresponds to the last pages of chapter 3 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

We have all the prerequisites created, so we start adding devices in the web GUI.

## Create a Device in UI
- From the left menu expand **DEVICES**
- Under the DEVICES  section click **Devices**
- In the center pane click **Add Device** (see also the "**+**") add button in the left menu
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
The provided CSV file contains device manufacturers and models. The module networktocode.nautobot.device requires the device_type ID instead.

This isn't a problem in our Lab because we use the manufacturer's model number as the device_type.

- Copy the file [devices.csv](devices.csv)
- Copy the playbook [08-devices.yml](ansible/08-devices.yml)
- Run the playbook `ansible-playbook 08-devices.yml`

## Other Ways to Discover and Add Devices
There are other ways to discover your network devices and add them. Nautobot plug-ins can use secrets to discover and identify systems along with network scanning to discover platforms and software versions.

### Adding Secrets for Discovery
For security reasons, Nautobot generally does not store sensitive secrets (device access credentials, systems-integration API tokens, etc.) in its own database. There are other approaches and systems better suited to this purpose, ranging from simple solutions such as process-specific environment variables or restricted-access files on disk, all the way through to dedicated systems such as Hashicorp Vault or AWS Secrets Manager.

This model does not store the secret value itself, but instead defines how Nautobot can retrieve the secret value as and when it is needed. By using this model as an abstraction of the underlying secrets storage implementation, this makes it possible for any Nautobot feature to make use of secret values without needing to know or care where or how the secret is actually stored.

Nautobot's built-in secrets providers:
- Environment Variable
- Text File

Other providers: https://github.com/nautobot/nautobot-app-secrets-providers

⚠️ Beware that any App can potentially access your secrets (e.g., display on screen), so only install Apps you trust. Any job can access your secrets and log them to job results. Any Git repo can add new Jobs to the system. Any user with access to one or more secrets can exploit this to access other secrets.

#### Text File Method
- Create a text file to contain the secret value
  - `mkdir secrets`
  - `echo -n vyos > secrets/vyos-username.txt`
  - `echo -n vyos > secrets/vyos-password.txt`
  - one file, one secret
- Create a secret in Nautobot set to the path of the file
  - Log in to nautobot (e.g., http://192.168.99.14:8001)
  - From the left pane click SECRETS then click Secrets
  - Click Add Secret
    - Name: vyos_username
    - Description: //optional//
    - Provider: Text File
    - Path: **Absolute filesystem path** to the file (e.g., `/opt/nautobot/secrets/vyos-username.txt`)
    - Click **Create**
  - Click Add Secret
    - Name: vyos_password
    - Description: //optional//
    - Provider: Text File
    - Path: **Absolute filesystem path** to the file (e.g., `/opt/nautobot/secrets/vyos-password.txt`)
    - Click **Create**
- Select each secret, then click Check Secret to confirm it is working

#### Environment Variable Method
- Log in as nautobot user
- Create .env file
  - vi .env
    - `NAUTOBOT_EXAMPLE_PASSWORD=mysecretpassword`
  -   `chmod 0600 .env`
- Configure the nautobot services to use the .env environment file
  - Service files to modify
    - /etc/systemd/system/nautobot.service
    - /etc/systemd/system/nautobot-worker.service
    - /etc/systemd/system/nautobot-scheduler.service
  - In each file, under `[Service]` add the line
    - `EnvironmentFile=/opt/nautobot/.env`
- Do a daemon reload
  - `sudo systemctl daemon-reload`
- Modify the .bashrc file, adding to the end
  - `set -o allexport`
  - `source /opt/nautobot/.env`
  - `set +o allexport`
- Reboot
- Create a secret in Nautobot
  - Log in to nautobot (e.g., http://192.168.99.14:8001)
  - From the left pane click SECRETS then click Secrets
  - Click Add Secret
    - Name: example_variable_password
    - Description: optional
    - Provider: Environment Variable
    - Variable: NAUTOBOT_EXAMPLE_PASSWORD
    - Click Create
- Select the new secret, then click Check Secret to confirm it is working

#### Create Secrets Group
- From the left pane click SECRETS then click Secrets Groups
- Click Add Secrets Group
  - Name: example_secrets_group
  - Description: optional
  - Secret Assignment
    - SSH username for Lab network devices
      - Access type: Generic
      - Secret type: Username
      - Secret: vyos_username
    - SSH password for Lab network devices
      - Access type: Generic
      - Secret type: Password
      - Secret: vyos_password
  - Click Create

### Using the Nautobot Device Onboarding plugin
The worker will reach out to the device and attempt to discover its attributes, including hostname, FQDN, IP address, device type, manufacturer, and platform. The app uses netmiko and NAPALM to attempt to automatically discover the OS and model of each device.

- Identify the App
  - From the left menu click APPS, then click Apps Marketplace
  - From the list of apps, click Device Onboarding
- Install the App - [instructions](https://docs.nautobot.com/projects/core/en/stable/user-guide/administration/installation/app-install/)
  - `pip install nautobot-device-onboarding`
  - `echo nautobot-device-onboarding >> local_requirements.txt`
  - modify nautobot_config.py to add the app's name to the PLUGINS list
  - Add app configuration to PLUGINS_CONFIG
 
~~~
PLUGINS = ["nautobot_plugin_nornir", "nautobot_ssot", "nautobot_device_onboarding"]

PLUGINS_CONFIG = {
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
    "nautobot_device_onboarding": {
        "default_ip_status": "Active",
        "default_device_role": "leaf",
        "skip_device_type_on_update": True
    }
}
~~~

- run `nautobot-server post_upgrade`
- `sudo systemctl restart nautobot nautobot-worker nautobot-scheduler`
- Verify app installed
  - APPS > Installed Apps
- Enable the Job Sync Devices From Network
  - Click JOBS > Jobs
  - Under Device Onboarding edit the job Sync Devices From Network
  - Check Enabled
  - Click Udpate
- Run the Job
  - Click the job Sync Devices From Network
  - Enter information about the device in the form
    - IMPORTANT VyOS is not currently supported. Hopefully they will add it in the future
    - Location: Lab
    - Namespace: Global
    - IPv4 addresses: 192.168.99.14
    - Port: 22
    - Timeout: 30
    - Set Management Only: **unchecked**
    - Device role: Router
    - Device status: Active
    - Interface status: Active
    - IP address status: Active
    - Secrets group: example_secrets_group
    - Platform: leave unset to allow auto-recognition of the platform
  - Click Run Job Now (DRYRUN)
    - VyOS, NAS, Unifi, Netgear devices are not supported and will fail
  - If you have one of the supported devices (https://docs.nautobot.com/projects/device-onboarding/en/latest/), uncheck Dryrun and Run the job

⚠️ default device role is "leaf". this doesn't exist. but we don't have a good default device type to use.

## Next Steps
You can now start to add your devices. Continue to [IP Addressing](5_IP_Addressing.md).
