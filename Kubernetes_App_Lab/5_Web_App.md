# Set Up Application
We are going to deploy a demonstration web app using an image downloaded from hub.docker.com. We will demonstrate using HAProxy in front of the web application on Kubernetes.

Overview:
- Nginx and PHP-FPM on Alpine Linux minimalist image from https://github.com/TrafeX/docker-php-nginx
- This image has the mysqli driver enabled but the PDO driver for mysql is disabled
  - PDO is the modern way to interfaces with of the various databases out there with minimal coding changes
  - *See https://www.w3schools.com/php/php_mysql_connect.asp*
- We created our own image with PDO support: https://github.com/doritoes/docker-php-nginx-app-server
  - This image installs php83-pdo_mysql and enables the pdo_mysql extension
- Our simple demonstration app is built on the base driver without PDO support, and will use mysqli
  - Source:https://github.com/doritoes/k8s-php-demo-app
  - Image: https://hub.docker.com/repository/docker/doritoes/k8s-php-demo-app
- This application does not use HTTPS. It is HTTP only.
  - Obviously don't use this in production as leaks credentials!
  - HOWEVER, may web applications are rolled these days without https because they are only accessible by a load balancer or reverse proxy that has the TLS certificate installed. The security is performed by the load balancer meaning the actual pods don't have the https overhead and complexity.

References:
- https://28gauravkhore.medium.com/how-to-configure-the-haproxy-using-the-ansible-and-also-how-to-configure-haproxy-dynamically-f18a55de3a66

🚧 Continue work here...

## Create Deployment
We are doing to create 2 pods and have them created on our “worker” nodes. Our demonstration app includes both liveness and readiness check URLs.

`k8s-deployment-web.yml`

## Create Service
Now we are going to expose the application to beyond the node.
`k8s-service-web.yml`

## Create Ansible Playbook to Deploy the Web App
Create Ansible playbooks to create and remove the web application containers.

`deploy-web.yml`

`destroy-web.yml`

## Deploy the Web Application
## Test the Web Application
## Configure HA Proxy
### Create the haproxy.cfg.j2 Template
`haproxy.cfg.j2`
### Install HAProxy
`haproxy-install.yml`
### TestHAProxy
### Optionally Remove the NodePort
`k8s-service-web.yml`
## Scaling
## Learn More
### Load Testing
### Confirm Liveness Tests are Working
### What If...?
