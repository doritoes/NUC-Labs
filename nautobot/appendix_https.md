# Access Nautobot Using https
The official process for securing Nautobot using https is standing up NGINX as a web server in front of the Nautobot WSGI.
- https://docs.nautobot.com/projects/core/en/stable/user-guide/administration/installation/http-server/

⚠️ These steps will configure a self-signed certificate (again, only suitable for a Lab like ours) and secure the user web interface. The API interface on port 8001 is still in clear text and subject to snooping the API keys.

⚠️ This process is currently FAILING in our Lab testing

## Create Self-signed Certificate
Two files will be created: the public certificate (nautobot.crt) and the private key (nautobot.key).
- `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nautobot.key -out /etc/ssl/certs/nautobot.crt`
  - Country Name: US
  - State: New York
  - City: New York
  - Organization name: nautobot lab
  - Organizational unit: lab
  - Common name: nautobot
  - Email address: n@n.lab

## Install NGINX
- `sudo apt install -y nginx`
- create the file `/etc/nginx/sites-available/nautobot.conf` from [nautobot.conf](nautobot.conf)
- `sudo rm -f /etc/nginx/sites-enabled/default`
- `sudo ln -s /etc/nginx/sites-available/nautobot.conf /etc/nginx/sites-enabled/nautobot.conf`
- `sudo usermod -aG nautobot www-data`
- `chmod 750 $NAUTOBOT_ROOT`
- `sudo systemctl restart nginx`
- Test https access (e.g., https://192.168.99.14), and accept the self signed certificate
- Troubleshooting
  - Note that Ubuntu doesn't start SELinux, so when troubleshooting don't be distracted by tips to setsebool httpd_can_network_connect
    - `sestatus`
  - Further configuration is required
  - curl -vvvLk http://localhost
  - sudo cat /var/log/nginx/error.log
  - `upstream prematurely closed connection while reading response header from upstream`

## Reconfigure uwsgi
- Modify `$NAUTOBOT_ROOT/uwsgi.ini`
  - From: `http = 0.0.0.0:8001`
  - To: `http-socket = localhost:8001`
  - This BREAKS http://192.168.99.14:8001
- `sudo systemctl restart nautobot`
- curl -vvvLk http://localhost
- still fails
- sudo systemctl restart nautobot
- sudo cat /var/log/nginx/error.log
- `upstream prematurely closed connection while reading response header from upstream`
