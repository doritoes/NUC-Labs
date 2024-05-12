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

## Create Deployment
We are doing to create 2 pods and have them created on our “worker” nodes. Our demonstration app includes both liveness and readiness check URLs.
- Create `k8s-deployment-web.yml` from [k8s-deployment-web.yml](k8s-deployment-web.yml)
- Apply the manifest: `kubectl apply -f k8s-deployment-web.yml`

Test the deployment:
- `kubectl get pods,deploy`
- `kubectl describe pods`
- `kubectl get pods -o wide`
  - there should be 2 pods on node2 and node3 (not node1)
- `kubectl exec -it <podname> – sh`
- Test web page from Host:
  - `kubectl port-forward <podname> 8080:8080`
  - http://localhost:8080

## Create Service
Now we are going to expose the application to beyond the node.

- Create `k8s-service-web.yml` from [k8s-service-web.yml](k8s-service-web.yml)
- Apply the manifest: `kubectl apply -f k8s-service-web.yml`

Test the service:
- You can now text access from the host system (or any device on the same network)
- Point your browser to the IP address of any worker node on the nodePort we set to 30080
  - `http://<ipaddress_node>:30080`
 
Clean up the deployment and the service:
- `kubectl delete -f k8s-deployment-web.yml`
- `kubectl delete -f k8s-service-web.yml`

## Create Ansible Playbooks to Deploy the Web App
Create Ansible playbooks to create and remove the web application containers.
- Create `deploy-web.yml` from [deploy-web.yml](deploy-web.yml)
- Create `destroy-web.yml` from [destroy-web.yml](destroy-web.yml)

## Deploy the Web Application
Test the playbooks to confirm the web app deploys correctly.
- `ansible-playbook deploy-web.yml`
- `kubectl get pods`
- `ansible-playbook destroy-web.yml`
- `kubectl get pods`
- `ansible-playbook deploy-web.yml`

## Test the Web Application
- Point your browser to the IP address of any worker node on the nodePort we set to 30080
  - `http://<ipaddress_node>:30080`
- Create an account and log in to see the very limited capabilities of the app

## Configure HA Proxy
We will demonstrate using HAProxy in front of the web application on Kubernetes. This is handy because it allows the nodes expose the application while load balancing the connections across all the pods.

IMPORTANT If you do this, remember you will need to reconfigure haproxy.cnf and gracefully reload haproxy for every addition/removal of pods.

BETTER SOLUTION is to automate HAProxy reconfiguration in response to pod changes

k8s sidecar container
monitors for changes to pods matching your backend label; could even use the utility kubewatch
template updates - update the template on the fly with new or removed pod IPs
mount your config as a ConfigMap, and have a sidecar modify it in place
HAProxy Reload - gracefully reload HAProxy after template modification
/path/to/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)
avoids interrupting active connections

### Create the haproxy.cfg.j2 Template
This basic configuration will load balance (round-robin method) across the “worker” nodes on port 8080.
- You can access the applciation via any node
- The node will pass the traffic to a pod on another node if need be
- Create `haproxy.cfg.j2` from [haproxy.cfg.j2](haproxy.cfg.j2)

### Install HAProxy
- Create `haproxy-install.yml` from [haproxy-install.yml](haproxy-install.yml)
- Run the playbeoook: `ansible-playbook haproxy-install.yml --ask-become`
  - enter the password for user `ansible` when prompted

### TestHAProxy
- Point your browser to the IP address of any worker node on the HAProxy port we configured
  - `http://<ipaddress_node>:8080`
- Try using the th IP address of all the worker nodes
- Reduce the number of replicas to 1
  - Edit `k8s-deployment.yml` to set **replicas: 1**
  - Apply `kubtcutl apply -f k8s-deployment.yml`
  - `kubectl get pods`
  - `kubectl describe pods`
- Repeat testing the application on each node IP address
  - The application works from both nodes, even if the pod is running on the node you are accessing!
  - 💡 In practice, you can set your application DNS name to round-robin pointing to one, two or more worker nodes
- Restore the number of replicas to 2
  - Edit `k8s-deployment.yml` to set **replicas: 2**
  - Apply `kubectl apply -f k8s-deployment.yml`
  - `kubetl get pods`
  - `kubectl describe pods`
- Compare performance between the HAProxy (port 8080) vs direct to the node (port 30080)

### What if - HAProxy - Pods
What if we wanted to deploy HAProxy to point to pods instead of NodePorts?
- In this use case you could remove the NodePorts and rely on HAProxy for external access to the application
- There are some major caveats!
  - Pods are recreated with a new IP address, that doesn't match the haproxy.cfg file we pushed out
  - haproxy service will fail on nodes as the expected Pod IP addresses fail
    - `sudo journalctl -xeu haproxy.service`
  - you will need to update the `haproxy.cfg files` and restart haproxy every time there is a change to the pods!

### HAProxy and Ingress Controller
What about better/smart load balancing?
- https://medium.com/@sujitthombare01/haproxy-smart-way-for-load-balancing-in-kubernetes-c2337f61d90b

## Learn More
### Scaling
You can quickly scale up or down the number of replicas in your deployment.

In one terminal session set up a watch of your pods and deployment status.
- `watch -d -n 1 'kubectl get pods,deploy'`

In another session run these commands and watch what happens
- `kubectl scale deployment/web-deployment --replicas=10`
- `kubectl scale deployment/web-deployment --replicas=2`
- `kubectl scale deployment/web-deployment --replicas=10`

Watch what happens when the deployment file is reapplied:
- `ansible-playbook deploy-web.yml`

Scaling isn't “permanent” if you don't update the yml file (manifest).

### Load Testing
These pods are only rated for a relatively small number of sessions. But let's test that out!
- https://stackify.com/best-way-to-load-test-a-web-server/

Install `autobench` on your host system:
- `sudo apt install apache2-utils`

Here is the basic syntax: `ab -n <number_of_request> -c <concurrency> <url>`

#### Using HAProxy
- refresh the configs: `ansible-playbook haproxy-install.yml`
- run 100 requests, 10 concurrently
  - `ab -n 100 -c 10 http://<nodeip>:8080/load.php`

#### Using NodePort
- run 100 requests, 10 concurrently
  - `ab -n 100 -c 10 http://<nodeip>:30080/load.php`

#### Comparisons
Try heavier benchmarking tests with a higher number of connections and concurrent connections.

Compare:
- 10000 connections, 10 current
- compare load.php vs index.php vs test.html
- 50000 connections, 100 current
  - the times in ms are maybe 10x higher, but if you login in to the application and use it while the test is running, do you notice any difference?
- if you increase to 10 replicas and reconfigure haproxy, will the performance get better or worse?

### Confirm Liveness Tests are Working
- In one terminal session set up a watch of your pods and deployment status:
  - `watch -d -n 1 'kubectl get pods,deploy'
- In another termial session list your web pods
- Open and interactive shell to one of the pods
  - `kubectl exec -it <podname> -- sh`
- Remove the `liveness.php file`
  - `rm liveness.php`
-  Watch how long it takes for the pod to be restart. Examine how the ready counters, status, restarts, and age are affected.
-  What happens if you remove the `readiness.php` file? What happens if you run the command `reboot`?

### What If...?
1. What will happen if your MySQL pod hangs? How will the application pods behave?
    - `kubectl get pods`
    - `kubectl delete pod <name of mysql pod>`
2. What happens if you remove the mysql deployment?
    - `ansible-playbook remove-sql.yml`
    - watch the pods restart 5 times; they never become ready
    - in the meantime, can you access the application? what happens when you try to log in?
    - after 5 restarts notice the status is CrashLoopBackOff
3. What happens if you re-deploy the mysql distribution?
    - `ansible-playbook deploy-sql.yml`
    -  Do the pods recover automatically?
