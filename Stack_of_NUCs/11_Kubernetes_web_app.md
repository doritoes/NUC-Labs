# Kubernetes - Deploy Web Application
Now we are going to install a web app and expose it to our internal network.

Purpose
- Demonstrate a running a web application on Kubernetes

References
- https://gitlab.com/doritoes/speedtester
- https://hub.docker.com/repository/docker/doritoes/speedtester/general
- https://docs.ansible.com/ansible/latest/collections/kubernetes/core/k8s_module.html
- https://opensource.com/article/20/9/ansible-modules-kubernetes

## Connect to the Ansible control node
- From NUC1, log in to the Ansible control node, NUC2
- `cd /home/ansible/my-project/k8s`

## Deploy a Distribution
- Create the `speedtester-deployment.yml` manifest ([speedtester-deployment.yml](k8s/speedtester-deployment.yml))
- Apply the deployment definition (in the yml file)
  - `kubectl apply -f speedtester-deployment.yml`
- View distribution information
  - `kubectl get pods,deployments`
  - `kubectl describe deployments speedtester`
  - `kubectl get deployment speedtester -o yaml`
- Increase number of replicas
  - Edit the file `speedtest-deployment.yml`
  - Modify `replicas: 2` to the number of worker nodes you have, or 4 (whichever is larger)
  - Reapply the definition
    - `kubectl apply-f speedtester-deployment.yml`
  - Watch the activity and changes
    - `kubectl apply-f speedtester-deployment.yml`
    - `kubectl get pods -w`
    - `kubectl get deployments`
    - `kubectl describe deployments speedtester`
    - `kubectl get deployment speedtester -o yaml`
## Create a Service
### Using Expose
- "Expose" the service
  - `kubectl expose deployment speedtester --port=8080 --name=speedtester-service --target-port=8080`
- Examine it: `kubectl describe svc speedtester-service`
  - Notice the type (ClusterIP)
  - Notice the service is exposed internally, but not from outside
- Remove it
  - `kubectl get svc`
  - `kubectl delete svc speedtester-service`
### Using a manifest
- Create the `speedtester-service.yml` manifest ([speedtester-service.yml](k8s/speedtester-service.yml))
- Apply the service definition (in the yml file)
  - `kubectl apply -f speedtester-service.yml`
- View results: `kubectl get all`
- Examine it: `kubectl describe svc speedtester-service`
  - Notice the type (NodePort)
  - It's not obvious, but the Nodes now expose the service on port 30080 on their own IP addresses

## Test Access
Point your web browser on NUC 1 (or any of your Lab systems) to the IP address of <ins>any node</ins> and the port we selected, port 30080.
- Example: `http://<IPADDRESSWORKERNODE>:30080`
- The speed test will now complete (will no longer crash during the upload test)
  - **NOTE** Look at the IP address that Speedtester returns; compare this across the different nodes
    - What does this tell you about the NodePort mechanism?
    - Confirm by viewing a pod's logs
      - `kubectl get pods`
      - `kubectl logs <pod_name>`
    - If your application needs to know the client's real IP addresses, what options are there? (Hint: X-Forwarded-For)
- Test every Node IP address
- Optional: reduce the number of replicas to less than the number of nodes
  - can you still run the speed test from ALL node IP addresses?
  - do you get different speed test results?

## Scaling
You can quickly scale up or down the number of replicas in your deployment.
- In one terminal session set up a watch of your pods and deployment status
  - `watch -d -n 1 'kubectl get pods,deploy'`
- In another session run these command and watch what happens
  - `kubectl scale deployment/speedtester --replicas=10`
  - `kubectl scale deployment/speedtester --replicas=2`
  - `kubectl scale deployment/speedtester --replicas=10`
  - `kubectl apply -f speedtester-deployment.yml`
 
Note that ad-hoc scaling is not a good idea for production: your scaling is not "permanent" unless you update the yml file (manifest).

## Learn More
### Managing Kubernetes using Ansible
Ansible can be used for managing Kubernetes.
- https://docs.ansible.com/ansible/latest/collections/kubernetes/core/k8s_module.html

#### Installing Kubernetes Python Package
Learn more about using Python to manage Kubernetes:
- https://www.velotio.com/engineering-blog/kubernetes-python-client

Installing the python module `kubernetes` using Ansible:
- Create the `install-python-kubernetes.yml` playbook ([install-python-kubernetes.yml](k8s/install-python-kubernetes.yml))
- Run the playbook
  - `ansible-playbook install-python-kubernetes.yml`

NOTE that compatibility issues exist between versions. This playbook specifies a specific version for module `openshift`.

#### Deploy with Ansible
This section uses the standard set out at https://opensource.com/article/20/9/ansible-modules-kubernetes.

Note the alternative approach at https://shashwotrisal.medium.com/kubernetes-with-ansible-881f32b8c53e, where the YAML files are copied and used.

Compare:
- Standard deployment file: [speedtester-deployment.yml](k8s/speedtester-deployment.yml)
- Playbook for same deployment: [ansible-deployment.yml ](k8s/ansible-deployment.yml)

NOTE that the ansible playbook requires specifying a namespace.

Run and verify:
- `ansible-playbook ansible-deployment.yml`
- `kubectl get pods`

#### Creating Namespaces
This an example use case from the documentation.

namespace.yml
~~~~
---
- hosts: master
  become_user: ansible
  tasks:
    - name: Create namespace
      k8s:
        name: my-namespace
        api_version: v1
        kind: Namespace
        state: present
~~~~
Run as: `ansible-playbook namespace.yml`

### Chaos Testing
Chaos engineering exercises the resiliency of a service by means of randomly or continually interrupting service.

Proper chaos testing:
- https://opensource.com/article/21/6/chaos-kubernetes-kube-monkey
- https://github.com/krkn-chaos/krkn

Some small scale chase testing is outlined below.

#### Kill Pods
You can watch what is happening a couple of ways:
- `watch kubectl get pods`
- `kubectl get pods -w`
- Open two windows, one to watch what happens while to "break" things in the other window

Literally kill the first pod in the list
  - `kubectl delete pod $(kubectl get pods -l run=speedtester -o jsonpath='{.items[0].metadata.name}')`

Forever loop to keep killing the first pod on the list
~~~~
while true; do
kubectl delete pod $(kubectl get pods -l run=speedtester -o jsonpath='{.items[0].metadata.name}')
done
~~~~

Kill all the current pods (slow because loop structure is sequential)
- [deletepod.yml](k8s/deletepod.yml]
- `ansible-playbook deletepod.yml`

Kill all the current pods but without waiting for confirmation
- [deletepod-async.yml](k8s/deletepod-async.yml]
- `ansible-playbook deletepod-async.yml`
- is it any faster?

#### Crash Pods
Crash the pods by killing the supervisord process
- [killpod-webservice.yml](k8s/killpod-webservice.yml)
- `ansible-playbook killpod-webservice.yml`
- How is this different from kill the pods?
  - How is the `kubectl get pods` output (Age and Restarts) different?
  - If you run this several times, what status will the pods change to before returning to "Running"?
  - What is the impact on application availability when we have pod crashes like this?

#### Rebooting Nodes
Rebooting nodes
- [randomreboot.yml](k8s/randomreboot.yml)
- `ansible-playbook randomreboot.yml`
- `watch 'kubectl get deploy,svc,nodes; kubectl get pods -o wide;'`
- What are does failure look like now?
  - Can you run the speedtest while a node is rebooting?
  - Do you need to change the IP do a different node IP address?
  - How long does it take to detect the lost pods on the missing node?
  - When do worker nodes show status *Unknown* on pods before returning to Running
  - Use `kubectl get pods -o wide`
- Once in a while the random selection hits the master node
  - watch to see what happens then

### kubedoom
kubedoom is the infamous k8s demonstration where you get to kill k8s pods and watch them respawn
- https://github.com/storax/kubedoom
- https://opensource.com/article/21/6/kube-doom
- https://www.youtube.com/watch?v=NGQhcJMSYDM
- https://www.youtube.com/watch?v=5uVrsWG1nKI

### kubeinvaders
kubeinvaders is another chaos tool were you kill k8s pods and watch them reappear
- https://github.com/lucky-sideburn/KubeInvaders
- Demo: https://kubeinvaders.platformengineering.it/#
