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
  - `kubectl apply -f speedtester-deployment.yml`
- View results
  - `kubectl get all`
  - `kubectl describe svc speedtester-service`
## Test Access
## Learn More
### Managing Kubernetes using Ansible
### Chaos Testing
