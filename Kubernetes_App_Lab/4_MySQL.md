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
To deploy MySQL on Kubernetes, we will use a Deployment object, which is a higher-level abstraction that manages a set of replicas of a pod. The pod contains the MySQL container along with any necessary configuration.

At the time of writing the latest mysql image being pulled is version 8.3.0 and runs on Oracle Linux Server 8.9. We will demonstrate using the base image, and mention an alternative image which enables the modern PDO driver.

There are three Kubernetes component parts we will use
- Deployment
- PersistentVolume (stored on the host aka Node)
- PersistentVolumeClaim

Finally, we will use Ansible to do the work.

### Deployment
Let's create the deployment manifest file for the MySQL server. 

The image documentation states that by mounting our mysql.sql ConfigMap to the pod at docker-entrypoint-initdb.d, the SQL script should automatically be processed when the pod deploys and there is no database yet.

However, in testing, we had to do a combination of things to get the configuration done:
- add a sleep command to allow the MySQL server to initialize fully; it will not accept any connections until that is complete
- we can't used the mounted location for our mysql command, so we copy the file from the mount the root, and execute from there

- Create `k8s-deployment-sql.yml` from [k8s-deployment-sql.yml](k8s-deployment-sql.yml)
- Apply the manifest: `kubectl apply -f k8s-deployment-sql.yml`

What happened and what didn't happen? Examine the output of the following commands
- `kubectl get pods`
- `kubectl get deployments`
- `kubectl describe deployments`

Our manifest refers to somethhing that doesn't exist yet!

Remove the deployment
- `kubectl delete -f k8s-deployment-sql.yml`

### PersistentVolume
By default, the MySQL pod does not have persistent storage, which means that any data stored in the pod will be lost if the pod is deleted or recreated. We are going to create a persistent volume that pods can mount. The actual storage is on the host (Node's file system).

- Create `k8s-pv.yml` from [k8s-pv.yml](k8s-pv.yml)
- Apply the manifest: `kubectl apply -f k8s-pv.yml`

Examine the output of the following commands
- `kubectl get pv`
- `kubectl describe pv`

Remove the physical volume
- `kubectl delete -f k8s-pv.yml`

### PersistentVolumeClaim
Now we will create a “reservation” for space on the persistent volume and give it a name.

- Create `k8s-pv.yml` from [k8s-pvc.yml](k8s-pvc.yml)
- We can create the persistent volume clame manually using kubect (but the persistent volume needs to exist)
  - Apply the manifest: `kubectl apply -f k8s-pvc.yml`

Examine the output of the following commands
- `kubectl get pvc`
- `kubectl describe pvc`

Remove the physical volume claim
- `kubectl delete -f k8s-pvc.yml`

💡 If you create all three things, the pod will come up! But for now, we want to deploy all these with Ansible. And we want to run a script to grant create a user and grant permissions.

### Exposing MySQL with a Service
The MySQL server should be accessible from other deployments in Kubernetes, but secure from outside access. By creating a Service object, we create a name and port that can be used to connect to the MySQL server. The other pods will be able to use the DNS name `sql-service`.

- Create `k8s-service-sql.yml` from [k8s-service-sql.yml](k8s-service-sql.yml)

Since we are building everything in the default namespace, the full link to our service is:
- `mysql://sql-service.default.svc.cluster.local:3306/database_name`

### Deploying MySQL with Persistent Storage using Ansible
This step deploys everything in the “default” namespace.
- Leverages the .yml files created above
- Mounts the MySQL configuration script so it can be run during the deployment
- Mounts the persistent storage space for the MySQL server to use
- Mounts a custom mysql configuration file to enable connections from other pods (the bind-address statement)

Steps:
- Create `deploy-sql.yml` from [deploy-sql.yml](deploy-sql.yml)
- Run the Ansible playbook
  - `ansible-playbook deploy-sql.yml`

 Take a look at the results by running
 - `kubectl get pod,node,deployment,pv,pvc,svc,cm`

 Confirm the new MySQL pod is running on "node1", where we want it
 - `kubectl describe pod`
 - Look for the line similar to: `Node: node1/192.168.99.202`

## Testing MySQL Server
Congratulations on your brand new MySQL server! In this step we are going do demonstrate that this MySQL server will retain its database across reboots, upgrades, and even deleting and re-creating the deployment.

### Connecting to the MySQL Server Pod
- First, identify the pod name
  - `kubectl get pods`
  - It will be named something similar to `mysql-deployment-6b455d9d57-qxd8q`
- Next, use the pod name to connect interactively
  - `kubectl exec -t <mysql-pod-name> -- bash`
  - Example: `kubectl exec -it mysql-deployment-6b455d9d57-qxd8q -- bash`

### Login Using mysql Command
After connecting interactively to the MySQL pod, test logging in from the command line
- `mysql -uroot -pyourpassword`
- `mysql -appuer -pmypass`

Take a look at what is there by default: (don't forget the trailing semicolon;)
- `show grants;`
- `show databases;`
- `select user,host from mysql.user;`
- `use app_db;`
- `show tables;`

Use `exit` or `quit` to exit.

### Demonstrating Persistence
Log back in to the pod and re-launch `mysql`

Here we will:
- create a database
- select the new database
- create a table in the database
- insert a row
- show the data we inserted
~~~~
CREATE DATABASE test;
USE test;
CREATE TABLE messages (message VARCHAR(255));
INSERT INTO messages (message) VALUES ('Hello, world!');
SELECT * FROM messages;
~~~~
Now we will create an ansible playbook to remove:
- the deployment and all the pods
- the persistent volume and the volume claim and the service

Steps to destroy and rebuild MySQL:
- Create `destroy-sql.yml` from [destroy-sql.yml](destroy-sql.yml)
- Examine before: `kubectl get pod,node,deployment,pv,pvc,cm`
- Run the playbook
  - `ansible-playbook remove-sql.yml`
- Examine after: `kubectl get pod,node,deployment,pv,pvc,cm`
- Redeploy MySQL
  - `ansible-playbook deploy-sql.yml`
- Watch redeploy progress: `kubectl get pod,node,deployment,pv,pvc,cm`

Steps to confirm data is still there:
- Get the new pod name
  - `kubectl get pods`
- Connnect to the new pod in an interactive session (again, substitute the actual pod name)
  - `kubectl exec -t <mysql-pod-name> -- bash`
- Connect to `mysql` again
  - `mysql -uroot -pyourpassword`
- Check the output of these commands
  - `show databases;`
  - `use test;`
  - `show tables;`
  - `SELECT * FROM messages;`
  - Use exit or quit to exit mysql.

Steps to completely destroy the MySQL pod <ins>and its data</ins>:
- This will remove and clear all persistent data
- Pay special attention to the final task where it delete the data from the host
- Create `destroy-sql.yml` from [destroy-sql.yml](destroy-sql.yml)
- Run the playbook: `ansible-playbook destroy-sql.yml`

Confirm the data is gone:
- Run the playbook: `ansible-playbook deploy-sql.yml`
- Repeat the steps to log in to the new MySQL node and confirm the test database with table messages is gone

## Learn More
### Use k8s Secrets to Pass MySQL root User Password
In this that we are using the environment variable approach to set the MySQL root user password for simplicity's sake. For a production environment, you want to remove passwords from all manifest (yml) files.

This is the poor way to do it in our lab:
~~~~
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: yourpassword
~~~~

There are a few ways to improve this:
- create the k8s secret (not described in this lab)
- in `k8s-desploy-sql.yml` pull the secret
~~~~
        env:
          - name: MYSQL_ROOT_PASSWORD
            valueFrom:
              secretKeyRef:
                key: MYSQL_ROOT_PASSWORD
                name: mysql-root-password
~~~~

### Backups and Restoration
For a production application, you would replicate your MySQL database to another node. For our lab you could simply take a snapshot of the SQL node's data directory at `/data/my-pv`.

You may want to use the mysql command itself to dump a database to file or restore from file.
~~~~
mysql -u [user name] –p [target_database_name] < [dumpfilename.sql]
~~~~

The following is an example to back up and then restore a database from/to a docker container. You can adapt the same commands to work with your MySQL pod under Kubernetes.

Backup
~~~~
$ docker exec some-mysql sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql
~~~~

Restore
~~~~
$ docker exec -i some-mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < /some/path/on/your/host/all-databases.sql
~~~~

### Allowing Remote Access
The reference mysql image we are using only allows Unix socket connections from the localhost. Since it is key for our application pods to access our MySQL service, we added a configuration file to allow remote TCP connections.

Next, we granted access from any IP addresses for the user `appuser`. The `%` as the host means any host can connect.

How is this secured? The service we configured for SQL only exposes the service internal to the k8s node. It is not exposed outside the node, and no external connection can be made.
