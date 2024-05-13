# Monitor NUC Health
How is the health of our NUC? The CPU is running very high utilization.

- Look at your CPU utilization
  - `htop`
    - press `q` to quit
  - you want to see high utilization
  - config.xml controls the utilization ('light', 'medium', 'full')
- Monitoring your CPU temperature
  - `sensors`
    - Note the CPU package and/or core temperatures
    - `sensors -f` will show in degrees Fahrenheit
  - Install `glances`
    - `sudo apt install glances -y`
    - `glances`
    - 👁️Note the temperatures shown at the left under `SENSORS`
- You can look for issues caused by system reboots or client crashes
  - `grep INTERRUPTED /var/lib/fahclient/log.txt`
  - `grep INTERRUPTED /var/lib/fahclient/log*`
  - If you are overclocking and see these messages, you need to dial back on the overclocking
