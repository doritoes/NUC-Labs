# Kubernetes Installation
Kubernetes, also known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications.

Now we are going to use Ansible to install Kubernetes with:
- one NUC "master node" this we can call NUC 3
- remaining NUCs as "worker nodes" on which containerized applications will run

Purpose:
- Demonstrate a running a complex workload of web applications on Kubernetes

References:
- [Kubernetes: Up & Running](https://www.goodreads.com/book/show/26759355-kubernetes) by O'Reilly
- https://github.com/brettplarson/nuctestlab
- https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
- https://github.com/torgeirl/kubernetes-playbooks

## Create a project folder for Kubernetes
- Log in to NUC2 as user `ansible`
- Create the `k8s` directory
  - `mkdir /home/ansible/my-project/k8s`
  - `cd /home/ansible/my-project/k8s`
- Create the `inventory` file
  - Use the example `inventory` ([inventory](k8s/inventory))
  - Modify it to include the IP address of one of your ansible nodes under `[master]`
  - Include the remaining IP addresses under `[workers]`
- Create the `ansible.cfg` file ([ansible.cfg](k8s/ansible.cfg))
  - this tells Ansible to use the `inventory` file
  - `ansible all -m ping`
  - `ansible master -m ping`
  - `ansible workers -m ping`

## Update the hosts files
- Create the `updatehostsfile.yml` playbook ([updatehostsfile.yml](k8s/updatehostsfile.yml))
- Run the playbook
  - `ansible-playbook updatehostsfile.yml`
  - This updates /etc/hosts in the master, workers, and also the Host (see how `localhost` is included)

## Install Prequisites
Install some prerequisites on ALL the Kubernetes nodes
- Create the `kube-dependencies.yml` playbook ([kube-dependencies.yml](k8s/kube-dependencies.yml))
- Run the playbook
  - `ansible-playbook kube-dependencies.yml`

🚧 Continue work here...

**FAILED STEP - Both Lab 1 and Lab 3**
~~~~
Failed to update apt cache:
The repository 'https://apt.kubernetes.io kubernetes-xenial Release' does not have a Release file.
Updating from such a repository can't be done securely, and is therefore disabled by default.
See apt-secure(8) manpage for repository creation and user configuration details.
https://download.docker.com/linux/ubuntu/dists/jammy/InRelease: Key is stored in legacy trusted.gpg keyring (/etc/apt/trusted.gpg), see the DEPRECATION section in apt-key(8) for details."
~~~~

## Install Kubernetes Master Node
Configure kubernetes cluster on master node
- Create the `master.yml` playbook ([master.yml](k8s/master.yml))
- Run the playbook
  - `ansible-playbook master.yml`
- SSH to the master node and verity the master node gets the status of `Ready`
  - `ssh <MASTER_IP> kubectl get nodes`

## Initialize Kubernetes Worker Nodes
- Create the `workers.yml` playbook ([workers.yml](k8s/workers.yml))
- Modify the playbook to replace **MASTERIP** with the IP of your master node in <ins> two (2) places</ins>
- Run the playbook
  - `ansible-playbook workers.yml`
- SSH to the master node and verity the that ALL the nodes get the status of `Ready`
  - `ssh <MASTER_IP> kubectl get nodes`

## Install kubectl on NUC2
Install kubectl on NUC 2 for automation with Kubernetes
- Create the `kubectlcontrolnode.yml` playbook ([kubectlcontrolnode.yml](k8s/kubectlcontrolnode.yml))
- Run the playbook
  - `ansible-playbook workers.yml`
- ⚠️ Running `kubectl version` will fail at this point because you do not have credentials
- Copy credentials
  - `scp <MASTER_UP>:/home/ansible/.kube ~/`
- Test that it is working
  - `kubectl version`
  - `kubectl get nodes`

## Install kubectl on NUC1
Install kubectl on NUC 1 for remote testing. In this case we will install manually, without Ansible.
~~~~
sudo apt update
sudo apt install -y ca-certificates curl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
~~~~
⚠️ Running `kubectl version` will fail at this point because you do not have credentials
- Copy credentials
  - `scp -r tux@<MASTER_UP>:/home/ansible/.kube ~/`
- Test that it is working
  - `kubectl version`
  - `kubectl get nodes`

## Learn More
Do some tests with Kubernetes.

### Manually Create Pod
1. `kubectl run speedtester --image=docker.or/doritoes/speedtester:latest
2. `kubect get pods`
    - Running `kutectl get pods -w` will "watch" the process of the container being created and changing status to `Running`; press control-c to exit
3. `kubectl describe pod speedtester`
4. `kubectl delete pods/speedtester`
    - this is the equivalent of `kubectl delete pod speedtester`

### Create Pod using Pod Manifest
1. Create the yaml file `speedtest-pod.yml` ([speedtest-pod.yml](k8s/speedtest-pod.yml)), or manifest 
2. Build the pod by applying the manifest
    - `kubectl apply -f speedtest-pod.yml`
3. Examine the pod
    - `kubectl get pods`
    - `kubectl describe pods speedtester`
4. Test connecting to the speedtester application on the pad
    - From NUC1
      - `kubectl port-forward speedtester 8080:80`
      - browse to http://localhost:8080
    - NOTE In testing port forwarding tended to break when the upload test started (“error creating error stream for port 8080 → 80: Timeout occurred”)
      - the worker node NUC didn't seem to have any load at all
        - kubectl exec -stdin -tty speedtester - /bin/bash
        - htop
      - one workaround is to keep relaunching the port-forward command
        - `while true; do kubectl port-forward speedtester 8080:80; done`
      - later on, we will demonstrate that is is stable when usig a better forwarding mechanism
5. Manage the pod
    - `kubectl logs speedtester`
    - `kubectl exec speedtester -- date`
    - `kubectl exec speedtester -- uname -a`
6. Delete the pod
    - `kubectl delete -f speedtest-pod.yaml`
    - `kubectl get pods`

### k9s
You can experiment running k9s on your Kubernetes master node. 
💡 What is [k9s](https://github.com/derailed/k9s/releases)? K9s is a terminal-based UI to interact with your Kubernetes clusters. The aim of this project is to make it easier to navigate, observe and manage your deployed applications in the wild. K9s continually watches Kubernetes for changes and offers subsequent commands to interact with your observed resources.

From the master k8s node:
- `mkdir k9s`
- `cd k9s`
- `wget https://github.com/derailed/k9s/releases/download/v0.27.3/k9s_Linux_amd64.tar.gz`
- `tar xzvf k9s_Linux_amd64.tar.gz`
- `./k9s`

### Kubernetes Dashboard
Experiment with managing your k8s environment using a Web UI.

References
- https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

1. Install dashboard
    - Log in to either NUC1 or NUC2
    - `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml`
2. Create a service account and bind the "cluster-admin" role to it
    - `kubectl create serviceaccount dashboard -n kubernetes-dashboard`
    - `kubectl create clusterrolebinding dashboard-admin -n kubernetes-dashboard  --clusterrole=cluster-admin  --serviceaccount=kubernetes-dashboard:dashboard`
3. Get a Bearer Token
    - `kubectl -n kubernetes-dashboard create token dashboard`
    - Copy the token, you will use it shortly
4. Access from NUC1
    - Log in to NUC1
    - `kubectl proxy`
    - UI can <ins>only be used from the machine where the command is executed</ins>
    - See `kubecpt proxy --help` for more options
    - From web browser on NUC1 open:
      - http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
    - Authenticate with "Token" and paste in the toekn from the previous step
5. Expert deploying containerized applications
    - https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
  
## Learn More
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
