#!/bin/bash
file="passwords.txt"
output="hashes.txt"
while read -r line
do
    /bin/echo -n "$line" | md5sum | cut -d' ' -f 1 >> "$output"
done < $file
