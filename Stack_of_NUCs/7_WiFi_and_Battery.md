# WiFi and CMOS Battery health check

## Check the WiFi on the NUCs
Sometimes in my Lab testing I find a NUC that seem slowing or become unresponsive. This can actually be due to a poor WiFi connection! (or a damaged antenna wire...)

1. Create file `/home/ansible/my-project/check-wifi.yml` with the contents of [check-wifi.yml](check-wifi.yml)
2. Run the playbook
    - `ansible-playbook -i hosts check-wifi.yml`


## CMOS Battery Check
Now we are going to create and run an Ansible playbook to check the CMOS battery health on the nodes. We are using /proc/driver/rtc instead of lm-sensors and sensors because it doesn't show the CMOS battery health on our NUCs.

Purpose:
- Demonstrate a simple lineinfile checker
- Check for any CMOS batteries that need to be replaced
- Demonstrate setting the hardware (RTC) clock from the system clock

1. Create file `/home/ansible/my-project/check-cmos.yml` with the contents of [check-cmos.yml](check-cmos.yml)
2. Run the playbook
    - `ansible-playbook -i hosts check-cmos.yml`
