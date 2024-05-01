# Set up Kubernetes
Now we are going to install Kubernetes on the VMs:
- The first will be the Kubernetes (k8s) master node
- The second will be the node that will run the SQL service (MySQL)
- The remaining VMs will be the “worker” nodes

Purpose:
- Demonstrate a running a web application workload on Kubernetes

References:
- [Kubernetes: Up & Running](https://www.goodreads.com/book/show/26759355-kubernetes) by O'Reilly
- https://github.com/brettplarson/nuctestlab
- https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
- https://github.com/torgeirl/kubernetes-playbooks

## Update inventory and ansible.cfg files
- Modify the `inventory` file to assign nodes to groups.
  - Example `inventory` file: [inventory](inventory)
  - Assign one node IP to `master`
  - Assign one node IP to `sql`
  - Assign remaining node IPs to `workers`
  - These IP addresses are the ones called out in `servers.yml`
- Create `ansible.cfg` from [ansible.cfg](ansible.cfg)
  - instructs Ansible to use the updated `inventory` file 
- You can now run an ansible “ping” with simply `ansible all -m ping`

## Update hosts File on All Nodes
Update the /etc/hosts files on all the nodes with the hostnames. This allows all nodes to resolve each other by name, but without DNS.

- Create `updatehostsfile.yml` from [updatehostsfile.yml](updatehostsfile.yml)
  - instructs Ansible to use the updated `inventory` file 
- Run the playbook `ansible-playboook updatehostsfile.yml --ask-become`

## Install Prerequisites
- Create `kube-dependencies.yml` from [kube-dependencies.yml](kube-dependencies.yml)
- Run the playbook `ansible-playbook kube-dependencies.yml`

## Install Kubernetes Cluster on Master Node
- Create `master.yml` from [master.yml](master.yml)
- Run the playbook `ansible-playboook master.yml`
- SSH to the master and verify the master node gets status `Ready`
  - `ssh controller kubectl get nodes`

## Set up the SQL Node
- Create `sql.yml` from [sql.yml](sql.yml)
- <ins>Modify the file</ins> to replace `MASTERIP` with the IP address of your master node in <ins>2 places</ins>
- Run the playbook `ansible-playboook sql.yml`

## Set up the Worker Nodes
- Create `workers.yml` from [workers.yml](workers.yml)
- <ins>Modify the file</ins> to replace `MASTERIP` with the IP address of your master node in <ins>2 places</ins>
- Run the playbook `ansible-playboook workers.yml`

## Install kubectl on the Host
Install kubectl on the host (the Ansible controller) to allow for automation with Kubernetes.

- Create `kubectlcontrolnode.yml` from [kubectlcontrolnode.yml](kubectlcontrolnode.yml)
- Run the playbook `ansible-playboook kubectlcontrolnode.yml --ask-become`
  - provide the password for the user `ansible` when prompted
- Running `kubectl version` will fail at this point because you don't have credentials
- Copy credentials
  - `scp -r controller:/home/ansible/.kube ~/`
- Confirm it's working now
  - `kubectl version`
  - `kubectl get nodes`

## Apply Labels to the Nodes
If you want to experiment with manually applying a label
- `kubectl label nodes node1 my-role=sql`
- `kubectl get nodes –show-labels`
- `kubectl describe nodes node1`
- `kubectl label nodes controller my-role-` (removes the label)

The following playbook will apply the appropriate labels to the nodes.

- Create `labels.yml` from [labels.yml](labels.yml)
- Run the playbook `ansible-playboook labels.yml`
- List nodes with labels
  - `kubectl get nodes --show-labels`
- View labels on a node
  - `kubectl desribe nodes node1`
