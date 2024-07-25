#!/bin/bash
# other ideas MySQL, PHP, openssh
# use weak ssh ciphers
# and install, configure vuln services like FTP; old version of workpress
# Check if Apache is installed
if ! dpkg -s apache2 >/dev/null 2>&1; then
  echo "Apache2 is not installed. Exiting..."
  exit 1
fi

# Get currently installed Apache version
apache_version=$(dpkg -l apache2 | grep '^ii' | awk '{print $3}')

# Define desired older version (modify with caution!)
desired_version="2.2.31"  # This is an example, choose a vulnerable version deliberately

# Check if desired version is older
if [[ $(dpkg --compare-versions "$desired_version" lt "$apache_version") == 0 ]]; then
  echo "Apache version $apache_version is already older than or equal to $desired_version. Exiting..."
  exit 1
fi

# **WARNING: Downgrading can cause issues. Proceed with caution!**
# Uninstalling current Apache version (risky, use with caution!)
echo "WARNING: This will uninstall the current Apache version ($apache_version). Proceed with caution!"
read -r -p "Are you sure you want to continue? (y/n) " response
case $response in
    [yY])
        sudo apt remove --purge apache2 apache2-common apache2-utils
        ;;
    *)
        echo "Exiting..."
        exit 1
        ;;
esac

# Attempting to install desired older version (risky, use with caution!)
echo "WARNING: This will attempt to install the older version ($desired_version). Proceed with caution!"
read -r -p "Are you sure you want to continue? (y/n) " response
case $response in
    [yY])
        sudo apt install apache2=<$desired_version
        ;;
    *)
        echo "Exiting..."
        exit 1
        ;;
esac

echo "Downgrade process complete (if successful). Remember, this script is for educational purposes only in a controlled lab environment!"

