# Initial Configuration
This corresponds to the latter part of chapter 3 in the book. See https://github.com/PacktPublishing/Network-Automation-with-Nautobot

You can't create objects without the required fields. So we need to do some pre-work to get things set up before we start creatings things.

## Device Prerequisites

- Devices (Step 7)
  - Role (Step 1)
  - Device Type (Step 3)
    - Manufacturer (Step 2)
  - Location (Step 5)
    - Location Type (Step 4)
  - Status (6)

## Roles

## Manufacturers
Import
- From the left menu expance **DEVICES**
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

```
#!/usr/bin/env python3
# if pyyaml is not installed by default: pip install pyyaml
import fnmatch
import json
import yaml
import os

file_matches = []
manufacturers = []
outfilename = 'manufacturers.csv'

# file the device-type yaml files
for root, dirnames, filenames in os.walk('devicetype-library/device-types'):
    for filename in fnmatch.filter(filenames, '*.yaml'):
        file_matches.append(os.path.join(root, filename))
# scrape all the manufacturers
for device_type_file in file_matches: 
    with open(device_type_file, 'r') as f:
        data = yaml.load(f, Loader=yaml.SafeLoader)
        if data['manufacturer'] not in manufacturers:
            manufacturers.append(data['manufacturer'])
            print(f"Added {data['manufacturer']}")
# dump csv of the sorted list of manufacturers
with open(outfilename, 'w') as outfile:
    outfile.write("name\n")
    outfile.write("\n".join(str(manufacturer) for manufacturer in sorted(manufacturers)))
print(f"Created file {outfilename} with {len(manufacturers)} manufacturers")
```

## Device Types
Import community library https://github.com/nautobot/devicetype-library

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


Device types > Import

## Location Types

## Locations

## Statuses

## Devices


## Next Steps

Continue to
