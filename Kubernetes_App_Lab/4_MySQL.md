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

## Create MySQL Deployment
## Testing MySQL Server
## Completely Destroy the MySQL Pod and its Data
## Redeploy the MySQL Pod and its Data
##Learn More
