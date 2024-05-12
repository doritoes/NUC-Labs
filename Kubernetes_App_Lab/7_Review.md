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

## Learn More
### SQL Security and sqlmap
Learn more by installing sqlmap and scan the test application for vulnerabilities.
🚧 continue writing here

### PDO drivers for SQL
🚧 continue writing here


Discussion about MySQLi vs PDO
- https://www.geeksforgeeks.org/what-is-the-difference-between-mysql-mysqli-and-pdo/
- https://phpdelusions.net/pdo/mysqli_comparison

- The main difference between PDO and MySQLi is that PDO is a data-access abstraction layer, while MySQLi is a specific implementation for MySQL
-  PDO provides an object-oriented approach. MySQLi provides a procedural way
