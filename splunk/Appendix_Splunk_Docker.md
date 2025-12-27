# Appendix - Splunk in Docker

## Preparation
1. Install Docker and Docker Compose (in my Lab I'm running on an Ubuntu Server 24.04 host)

## Install
1. Create the docker-compose.yml ([docker-compose.yml](docker-compose.yml)) file
2. Modify the file to specify your desired password
3. `sudo docker compose up -d`
4. Wait about 2 minutes for the setup scripts to run
  - `sudo docker logs -f splunk-enterprise`

## Access the UI
- Navigate to http://<your-ubuntu-ip>:8000
  - Username: `admin`
  - Password: *the password set in the docker compose file*
 
## Managing Splunk Container
- Stop Splunk: `sudo docker compose stop`
- Start Splunk: `sudo docker compose start`
- Destroy & Reset: `sudo docker compose down -v` (Removes the data volumes!)
- Update Splunk: `sudo docker compose pull && sudo docker compose up -d`
- Enter Console: `sudo docker exec -it splunk-enterprise bash`

## Mapping a Log Folder
Let's create a local "drop" folder on the Ubuntu server. Drop any syslog, CVS, web logs file into this server and it will appear in Splunk seconds later.

1. Create drop folder
  - `mkdir -p ~/splunk_data/inputs`
  - `sudo chown -R 1001:1001 ~/splunk_data/inputs`
    - this command looks sketchy
2. Update docker-compose.yml
  - Add mapping under the `volumes:` section of the Splunk service:
    - `/home/<your-username>/splunk_data/inputs:/opt/splunk/external_logs:ro`
    - Be sure to modify with your username
3. Restart Splunk
  - `sudo docker compose up -d`
4. Configure Splunk to "Watch" that folder
  - Log into Splunk Web (http://your-ip:8000).
  - Go to Settings > Data Inputs
  - Click Files & Directories
  - Click New Local Input
  - In the "File or Directory" box, type the Internal Container Path: /opt/splunk/external_logs
    - Note: Do NOT use the Ubuntu host path here; Splunk only sees the inside of the container.
  - Click Next, choose a Source Type (e.g., linux_messages_syslog or just auto), and click Review > Submit
5. Test it
  - `cp /var/log/auth.log ~/splunk_data/inputs/test_auth.log`
  - Without about 30 seconds go to Search and Reporting app in Splunk
    -   `index=main source="/opt/splunk/external_logs/test_auth.log"
  - NOTE if you selected "Continuous Monitor" when setting up the data input, you can append data to the data files and Splunk will stream in the new lines in real-time
    - `echo "Test security alert" >> ~/splunk_data/inputs/test_auth.log`
  
