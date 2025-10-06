#!/usr/bin/env python3
"""
git clone https://github.com/nautobot/devicetype-library
python3 scrape-manufacturers.py
inputs libary of nautobot device-types
creates output file manufacturs.csv
"""
import os
import fnmatch
import yaml

file_matches = []
manufacturers = []
OUTFILENAME = 'manufacturers.csv'

# find the device-type yaml files
for root, dirnames, filenames in os.walk('devicetype-library/device-types'):
    for filename in fnmatch.filter(filenames, '*.yaml'):
        file_matches.append(os.path.join(root, filename))
# scrape all the manufacturers from the files
for device_type_file in file_matches:
    with open(device_type_file, 'r', encoding="utf-8") as f:
        data = yaml.load(f, Loader=yaml.SafeLoader)
        if data['manufacturer'] not in manufacturers:
            manufacturers.append(data['manufacturer'])
            print(f"Added {data['manufacturer']}")
# dump csv of the sorted list of manufacturers
with open(OUTFILENAME, 'w', encoding="utf-8") as outfile:
    outfile.write("name\n")
    outfile.write("\n".join(str(manufacturer) for manufacturer in sorted(manufacturers)))
print(f"Created file {OUTFILENAME} with {len(manufacturers)} manufacturers")
