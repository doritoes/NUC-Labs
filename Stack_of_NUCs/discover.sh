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
  # set up SSH managment keys
  ssh-keygen -q -R $i && ssh-keyscan -H $i >> ~/.ssh/known_hosts
  # identify hosts ansible can access
  ssh -q -o PasswordAuthentication=No $i "hostname -I" && echo $i && echo $i >> $OUTPUT
done
