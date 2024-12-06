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
