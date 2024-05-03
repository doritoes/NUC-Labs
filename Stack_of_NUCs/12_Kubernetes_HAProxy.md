# Kubernetes - Test HAProxy
Now we are going to install HAProxy.

Purpose:
- Demonstrate a using HAProxy in front of a web application on Kubernetes
References:
- https://28gauravkhore.medium.com/how-to-configure-the-haproxy-using-the-ansible-and-also-how-to-configure-haproxy-dynamically-f18a55de3a66

🚧 Continue building here from https://www.unclenuc.com/lab:stack_of_nucs:ansible_playbook_-_install_haproxy

## Create project folder for HAProxy Configuration and Playbooks
- From NUC1, log in to the Ansible control node, NUC2 as user `ansible`
- Log in to NUC2 as user `ansible`
- Create the `haproxy` directory
- `mkdir /home/ansible/my-project/haproxy`
- `cd /home/ansible/my-project/haproxy`
- Copy the `inventory` and `ansible.cfg` files
  - `cp /home/ansible/my-project/k8s/inventory /home/ansible/my-project/haproxy/`
  - `cp /home/ansible/my-project/k8s/ansible.cfg /home/ansible/my-project/haproxy/`
- Test using `ansible all -m ping`

## Install HAProxy
Here we will use HAProxy to distribute load to the worker node IP addreses via the service port 30080.
- Create the `haproxy.cfg.j2` file ([haproxy.cfg.j2](haproxy/haproxy.cfg.j2))
- Create the `haproxy-install.yml` playbook ([haproxy-install.yml](haproxy/haproxy-install.yml))
- Run the playbook
  - `ansible-playbook haproxy-install.yml`
  - This updates /etc/hosts in the master, workers, and also the Host (see how `localhost` is included)

## Test HAProxy
1. Point your browser to http://<IPANYK8SWORKENODE>:8080/
2. Test that any of the nodes will service the app from any pod on andy node
    - Change directory to `/home/ansible/my-project/k8s`
    - Edit `speedtester-deployment.yml` and change the number of replicas to **1**
    - `kubectl apply -f speedtester-deployment.yml`
    - Use `kubectl get pods` to watch the pods terminated until 1 is left running
    - Point your browser to each K8s worker node IPs with port 8080
      - is the app up?
3. Revert the change to `speedtester-deployment.yml` and re-apply it

## Learn More
