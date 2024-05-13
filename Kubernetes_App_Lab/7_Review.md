# Review
Congratulations! You successfully completed a WHOLE lot of automation!
- Installed and configured Oracle VirtualBox using Ansible
- Deployed a fleet of auto-installed virtual Ubuntu servers
- Provisioned Kubernetes on these servers
- Deployed a MySQL service
- Deployed a demonstration web application that consumes the MySQL service

There are clearly things to consider to deploy an actual production web application. Here are a few things you can experiment with:
- create a playbook to bring the environment back up when the host reboots
- use of Kubernetes secrets instead of environment variables to configure the MySQL root password
- configure a Nginx virtual system for SSL Termination
- fork your own demo application and add https support
- Prometheus Node Exporter: explore metrics at the node (system) level; relatively easy to set up, it exposes useful metrics about host machine resources
- CI/CD Pipelines: Investigate a simple pipeline (Jenkins, GitLab CI, etc) to automate building a container image for your web app and trigger Deployments when code changes.

## Clean Up
All it takes is a few seconds and the entire environment is erased:
- `ansible-playbook destroy_fleet.yml`

The short and concise steps to rebuild:
- `ansible-playbook destroy_fleet.yml`
- optionally update `servers.yml`
- `ansible-playbook build_fleet.yml`
- `ansible-playbook -i inventory configure_fleet.yml`
- `ansible -i inventory all -m ping`
- modify the `inventory` file
  - assign one IP address to `[master`]
  - assign one node IP to `[sql]`
  - assign remaining node IPs to `[workers]`
  - See [example](inventory)
- `ansible-playbook updatehostsfile.yml --ask-become`
- `ansible-playbook kube-dependencies.yml`
- `ansible-playbook master.yml`
- `ansible-playbook sql.yml`
  - NOTE update the master IP address if you changed it
- `ansible-playbook workers.yml`
  - NOTE update the master IP address if you changed it
- `ansible-playbook labels.yml`
- `ansible-playbook deploy-sql.yml`
- `ansible-playbook deploy-web.yml`
- Optionally, `ansible-playbook haproxy-install.yml --ask-become`

## Learn More
### SQL Security and sqlmap
Since we are exposing a SQL database via the web app, it is important to consider security. This is an opportunity to get expericence using the `sqlmap`tool.

For information on installing sqlmap: https://github.com/sqlmapproject/sqlmap
- `cd ~`
- `git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev`
- `cd sqlmap-dev`

Let's run it against out application, pointing to the nodeIP:
- `python3 sqlmap.py http://<node ip address>:30080/index.php --wizard`
- `python3 sqlmap.py http://192.168.99.203:30080/index.php --forms --crawl=2`

Now let's do a series of authenticated attacks:
- Log in to yhour account and learn your PHPSESSIONID cookie (ex., `i8s4i2lbp4b2ot8qftr92bijcl`)
  - For example use Chrome and F12, network > headers > request headers > cooke > PHPSESSID
- `python3 sqlmap.py --url http://192.168.99.203:30080/update.php --cookie='PHPSESSID=i8s4i2lbp4b2ot8qftr92bijcl' --dbs --forms crawl=2`
- `python3 sqlmap.py --url http://192.168.99.203:30080/update.php --cookie='PHPSESSID=i8s4i2lbp4b2ot8qftr92bijcl' --dbs --forms crawl=2 --level 5`
  - View your account details in the app. Were any changed? This is not intended, but can happen.
- `python3 sqlmap.py --url http://192.168.99.203:30080/unregister.php --cookie='PHPSESSID=i8s4i2lbp4b2ot8qftr92bijcl' --dbs --forms crawl=2 --level 5`

Look at how a sqlmap attack looks in the logs:
- `kubectl get pods`
- `kubectl logs <podname>`

The very simple application does not use index values or direct values to look up information. However, this is not mean the application is immune my SQL injection or XSS.

Why should `index.php` targeted for investigation of XSS?

### PDO drivers for SQL
🚧 continue writing here

Discussion about MySQLi vs PDO
- https://www.geeksforgeeks.org/what-is-the-difference-between-mysql-mysqli-and-pdo/
- https://phpdelusions.net/pdo/mysqli_comparison

- The main difference between PDO and MySQLi is that PDO is a data-access abstraction layer, while MySQLi is a specific implementation for MySQL
-  PDO provides an object-oriented approach. MySQLi provides a procedural way
