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
  - `kubectl describe deloyments speedtester`
  - `kubectl get deployment speedtester -o yaml`
- Increase number of replicas
- 
## Create a Service
## Test Access
## Learn More
### Managing Kubernetes using Ansible
### Chaos Testing
