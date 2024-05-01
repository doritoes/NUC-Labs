# MySQL Server
Now that we have Kubernetes up and running, we will get our MySQL container up and running. We will need storage for the SQL database so that it isn't lost the pod is deleted or recreated. We also want the MySQL container/pod to run on a specific mode which has more resources.

References:
- https://hub.docker.com/_/mysql
- https://www.tutorialspoint.com/deploying-mysql-on-kubernetes-guide
- https://ubuntu.com/server/docs/databases-mysql
- https://stackoverflow.com/questions/15663001/remote-connections-mysql-ubuntu
- https://blog.devart.com/how-to-restore-mysql-database-from-backup.html
- https://medium.com/@shubhangi.thakur4532/how-to-deploy-mysql-and-wordpress-on-kubernetes-8ea1260c27dd

**IMPORTANT** In this lab we are using the environment variable approach to set the MySQL root user password. See the **Learn More** section for ideas to improve on this in production.

🚧 Continue building here...

## Create MySQL Deployment
To deploy MySQL on Kubernetes, we will use a Deployment object, which is a higher-level abstraction that manages a set of replicas of a pod. The pod contains the MySQL container along with any necessary configuration.

At the time of writing the latest mysql image being pulled is version 8.3.0 and runs on Oracle Linux Server 8.9. We will demonstrate using the base image, and mention an alternative image which enables the modern PDO driver.

There are three Kubernetes component parts we will use
- Deployment
- PersistentVolume (stored on the host aka Node)
- PersistentVolumeClaim

Finally, we will use Ansible to do the work.

### Deployment
`k8s-deployment-sql.yml`

### PersistentVolume
`k8s-pv.yml`

### PersistentVolumeClaim
`k8s-pvc.yml`

### Exposing MySQL with a Service
`k8s-service-sql.yml`

### Deploying MySQL with Persistent Storage using Ansible
`deploy-sql.yml`

## Testing MySQL Server
Congratulations on your brand new MySQL server! In this step we are going do demonstrate that this MySQL server will retain its database across reboots, upgrades, and even deleting and re-creating the deployment.

### Connecting to the MySQL Server Pod

### Login Using mysql Command

### Demonstrating Persistence
`remove-sql.yml`

## Completely Destroy the MySQL Pod and its Data
`destroy-sql.yml`

## Redeploy the MySQL Pod and its Data


## Learn More
### Use k8s Secrets to Pass MySQL root User Password
### Backups and Restoration
### Allowing Remote Access
