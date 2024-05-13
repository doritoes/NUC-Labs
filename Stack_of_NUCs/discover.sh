#!/usr/bin/bash
if [ "$#" -ne 1 ]
then
  echo "Usage: $0 filename.txt"
  echo "results will be appended to this file"
  exit 1
fi
OUTPUT=$1
[[ ! -z "$OUTPUT" ]] && touch $OUTPUT || exit
IPs=$(sudo arp-scan --localnet --numeric --quiet --ignoredups | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' | awk '{print $1}')
touch ~/.ssh/known_hosts
for i in ${IPs}; do
  # set up SSH management keys, replace existing keys
  ssh-keygen -q -R $i 2>/dev/null
  ssh-keyscan -H $i >> ~/.ssh/known_hosts 2>/dev/null
  # identify hosts ansible can access, add to output file
  ssh -q -o PasswordAuthentication=No -o ChallengeResponseAuthentication=No -o ConnectTimeout=10 $i "hostname -I" && echo $i >> $OUTPUT
done
