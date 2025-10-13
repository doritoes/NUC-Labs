#!/usr/bin/env python3
"""
git clone https://github.com/nautobot/devicetype-library
python3 scrape-device-types-interfaces.py
inputs directory of yaml files of device types
oututputs CSV for Ansible to parse and add interfaces to device-type
"""
import os
import fnmatch
import yaml

file_matches = []
manufacturers = []
OUTFILENAME = 'device-types-interfaces.csv'

# find the device-type yaml files
for root, dirnames, filenames in os.walk('devicetypes'):
    for filename in fnmatch.filter(filenames, '*.yaml'):
        file_matches.append(os.path.join(root, filename))
# scrape all the manufacturers from the files and output to CSV
with open(OUTFILENAME, 'w', encoding="utf-8") as outfile:
    outfile.write("devicetype,name,type\n")
    for device_type_file in file_matches:
        with open(device_type_file, 'r', encoding="utf-8") as f:
            data = yaml.load(f, Loader=yaml.SafeLoader)
            if data and 'model' in data:
                print(data['model'])
                for interface in data['interfaces']:
                    print(f"{interface['name']} = {interface['type']}")
                    outfile.write(f"{data['model']},{interface['name']},{interface['type']}\n")
