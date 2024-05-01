# Custom ISO Unattended Ubuntu Install ISO
A custom “user-data” file is required for an unattended installation of Ubuntu. We will create this template file for use in our Ansible playbook.

## Create the user-data Template for Unattended Installation
- Create the jinja template `user-data.j2` from this repo ([user-data.j2](user-data.j2))
- Examine the variables used by the template
  - they are enclosed in `{{ }}`
  - the values will come from the `variables.yml` file

## Create the variables.yml File
- Create the file `variables.yml` ([variables.yml](variables.yml))
- <ins>Modify</ins> the file
  - Replace **bridge_interface_name** with the network interface you will bridge the VMs to
    - Linux: use `ip a` command to list interfaces
      - Example: `eth0`, `ens32`, or similar
    - Windows: use `ipconfig /all` command to list interfaces
      - use the `description` line
      - Example: `"Intel(R) Wi-Fi 6E AX211 160MHz"` instead of "Wireless LAN adapter Wi-Fi"
  - Set **username** to be the user you will use to manage the VMs
  - Set **ssh_key** to the value from the [previous step](1_Host.md#generate-keys-for-management)
    
## Generate Custom Unattended Ubuntu Install ISO
- Create the file `create_custom_iso.yml` ([create_custom_iso](create_custom_iso))
- Run the playbook
  - `ansible-playbook create_custom_iso.yml --ask-become-pass`
  - provide the sudo password when prompted
 
## Learn More
### Testing the ISO
Now that you have the ISO created, you can test it in Oracle Virtualbox, VMware Workstation, or on ESXi. Boot from the ISO and observe the steps.

If the boot is crashing, test out different settings (e.g. 2 or more vCPUs).

Above the login screen the prompt should list the IP address of the server. If there is no IP address, it could not resolve an IP address.

When customizing the playbook, you can use `ansible-lint` to help you find errors
- `sudo apt install ansible-lint`
- `ansible-lint create_custom_iso.yml`
