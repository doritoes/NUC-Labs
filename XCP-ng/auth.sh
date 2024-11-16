# example auth.sh script to run on the SMS and the gateways
# entering your key and running this script sets up the ansible automation to work
# example
# scp auth.sh ansible@192.168.41.20:~/
# ssh ansbile@192.168.41.10 "bash auth.sh"
mkdir ~/.ssh
chmod u=rwx,g=,o= ~/.ssh
touch ~/.ssh/authorized_keys
chmod u=rw,g=,o= ~/.ssh/authorized_keys
echo "paste-key-herey" > ~/.ssh/authorized_keys
