# Initial Configuration
This corresponds to the latter part of chapters 3 and 10 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

You can't create objects without the required fields. So we need to do some pre-work to get things set up before we start creatings things.

## Create API token for CRUD Operations
- Click **admin** in the lower-left corner (your logged-in user)
- Clikc **Profile**
- Clikc **API Tokens**
- Click **+ Add a Token**
- Add create a token and record it for later use
  - Ex. `nautobot-lab-token-crud-123456789-abcdefghij`

## Device Prerequisites
To set up the first devices you need to do some steps before finally creating the devices.
- Devices (Step 7)
  - Role (Step 1)
  - Device Type (Step 3)
    - Manufacturer (Step 2)
  - Location (Step 5)
    - Location Type (Step 4)
  - Status (6)

Device Families can be optionally used to group similar device types.

## Roles
Represents the logical role a device might have. Examples follow:
- leaf
- spine
- core router
- access switch
- border router

Some common roles you might have in your home lab are provided.

Import
- From the left menu expand **ORGANIZATION**
- Under **METADATA** click **Roles**
- Click the <ins>drop down</ins> for Add Role
- Click **Import from CSV**
  - Option 1: Use the prepared file 🌱 [roles.csv](roles.csv)
    - content_types (required) *usually dcim.device*
    - name (required)
    - color (optional)
    - description (optional)
    - weight (optional)

## Manufacturers
Represents the name of a device's manufacturer. Used in Device Types.

Examples follow:
- Cisco
- Arista
- from Juniper

Import
- From the left menu expand **DEVICES**
- Click **Manufacturers**
- Click the <ins>drop down</ins> for Add Manufacturer
- Click **Import from CSV**
  - Option 1: Use the prepared file in this lab: [manufacturers.csv](manufacturers.csv)
  - Option 2:
    - Use the provided script [scrape-manufacturers.py](scrape-manufacturers.py) to collect the latest list yourself
    - Log in as `nautobot` in its home directory
    - `git clone https://github.com/nautobot/devicetype-library`
    - `python3 scrape-manufacturers.py`
    - The file `manufacturers.csv` is created in the home directory
    - Then add any additional manufacturers missing from the list
      - Asus

## Device Families
Represents a group of related device types. Optionally used in Device Types.

For example:
- Device family: Cat9000
- Device types:
  - Cat9200
  - Cat9300

Not used in this Lab.

## Device Types
Represents the model of the device, which determines characteristics like interfaces. Examples follow:
- DCS-7010T-48-F (from Arista)
- MX480 (from Juniper)

Required fields:
- Manufacturer (e.g. Cisco)
- Model (e.g. A900-IAMC)
- Height (1, check Is full depth)

TIP Import from community library https://github.com/nautobot/devicetype-library

Import
- From the left menu expance **DEVICES**
- Click **Device Types**
- Click the <ins>drop down</ins> for Add Device Type
- Click **Import from JSON/YAML (single record)**
  - Navigate https://github.com/nautobot/devicetype-library/tree/main/device-types to find the vendor and device type
  - Inside the vendor file, find the device type yaml file
    - Example: Netgear GS116Ev2.yaml
  - Paste the data into the Data field and click **Submit** or **Submit and Import Another**
- Click **Import from CSV (multiple records)**
  - Content type: dcim | device type (default)
  - Choose File and click **Run Job Now**
 
- In my Lab I imported the following (provided in this repo)
  - [Netgear GS110TPv3.yaml](device-types/GS110TPv3.yaml)
  - [Netgear GS116Ev2.yaml](device-types/GS116Ev2.yaml) ([official](https://github.com/nautobot/devicetype-library/blob/main/device-types/Netgear/GS116Ev2.yaml))
  - [Unifi USW-Lite-16-PoE.yaml](device-types/USW-Lite-16-PoE.yaml) ([official](https://github.com/nautobot/devicetype-library/blob/main/device-types/Ubiquiti/USW-Lite-16-PoE.yaml))
  - [Unifi UAP-FlexHD.yaml](device-types/UAP-FlexHD.yaml) ([official](https://github.com/nautobot/devicetype-library/blob/main/device-types/Ubiquiti/UAP-FlexHD.yaml))
  - [Unifi U7-Pro.yaml](device-types/U7-Pro.yaml)
  - [Synology DS224+.yaml](device-types/DS224+.yaml)
  - [Qotom Q555G6-S05.yaml](device-types/Q555G6-S05.yaml)
    - Qotom-Q555G6-S05 Qotom Mini PC Intel Core i5 7200U Industrial Micro PC Barebone System Dual Core Desktop Small Computer with 6 Gigabit Ethernet NIC; used as firewall running pfSense
  - Intel NUC NUC10i7FNH1 Intel Core i7-10710U  ([NUC10i7FNH1.yaml)[device-types/NUC10i7FNH1.yaml])
    - running proxymox
  - Asus NUC NUC14RVH ([NUC14RVH.yaml](device-types/NUC14RVH.yaml)) 🌱 added ASUS manufacturer to manufacturers.csv
    - running XCP-ng

## Location Types
From the left menu click **Organization** > **Location Types**
- Click **Add Location Type**
- Name:  **Site**
- Content types: **dcim | device**
- Click **Create**

## Locations
Represents the site where the device is installed. Some examples:
- a city
- a building
- a room

requires:
- location type
- name
- status

optionally:
- parent
- facility (example data center prvider and facility such as Equinix NY7)
- ASN (BGP ASN number)
- timezone
- description

From the left menu click **Organization** > **Locations**
- Click **Add Location**
- Type: **Site**
- Name: **Lab**
- Status: **Active**
- Time Zone: *set to your local Time Zone*
- Click **Create**

## Tags
Create tag for management interfaces.

From the left menu click **Organization** > **METADATA**
- Under METADATA click **Tags**
- Click **Add Location Type** and then click **Add Tag**
  - Name: **Management**
  - Description: **Management interface**
  - Content Type(s): **dcim | interface** 
  - Click **Create**

## Statuses
Represents the status of a device. Comes with prepopulated list and you can add your own. Examples follow:
- Active
- Decomissioning
- Planned

No custom statuses are required for this Lab.

## Next Steps
You can now start to add your devices. Continue to [Adding your First Devices](3_Adding_Devices.md).
