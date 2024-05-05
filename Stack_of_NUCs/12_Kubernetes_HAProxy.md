# Kubernetes - Test HAProxy
Now we are going to install HAProxy.

Purpose:
- Demonstrate a using HAProxy in front of a web application on Kubernetes
References:
- https://28gauravkhore.medium.com/how-to-configure-the-haproxy-using-the-ansible-and-also-how-to-configure-haproxy-dynamically-f18a55de3a66

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

## Test HAProxy - Nodes
First we will deploy HAProxy pointing to the nodes
1. Point your browser to `http://<IPANYK8SWORKERNODE>:8080/`
2. Test using every worker node IP address
3. Test with only 1 replica
    - change directory back to `/home/ansible/my-project/k8s/`
    - edit `k8s-deployment-web.yml` to set replicas: **1**
    - apply it: `kubectl apply -f speedtester-deployment.yml`
    - confirm number of pods down to 1: `kubectl get pods`
    - confirm which node it is running on:
      - `kubect get pods -o wide`
    - repeat testing of each node IP address to confirm everything still works
    - reboot that node, and watch what happens you the application
      - does the pod move to another node?
      - is the application accessible via a different node? why or why not?
      - how long does it take until the application starts working again?
    - in practice, you can set your application's DNS name to "round-robin" to point to one, two, or more worker nodes
5. Test with more replicas
    - edit `speedtester-deployment.yml` to set replicas: **2** (or more!)
    - apply it: `kubectl apply -f speedtester-deployment.yml`
    - confirm number of pods has increased: `kubectl get pods`
    - ssh to a node that lost all it's pods
      - it has pods again
      - ⚠️ Uh oh there is a problem!: `sudo journalctl -xeu haproxy.service`
      - The pod was created with a new IP address that doesn't match the haproxy.cfg file we pushed out.
      - Since this is a Lab, we can handle the interruption of a regular restart
        - `ansible-playbook haproxy-install.yml`
      - ssh to each node and note the status of the HAProxy service
        - `systemctl status haproxy`
    - Edit `speedtester-deployment.yml` and change the number of replicas to **1**
    - `kubectl apply -f speedtester-deployment.yml`
    - `sudo journalctl -xeu haproxy.service`
6. Do you see any difference in the speedtest results via HAProxy (port 8080) vs direct to the node (port 30080)?

## What if - HAProxy - Pods
What if we wanted to deploy HAProxy to point to <ins>pods</ins> instead of NodePorts?
- In this use case you could remove the NodePorts and rely on HAProxy for external access to the application
- There are some <ins>major caveats</ins>!
  - Pods are recreated with a new IP address, that doesn't match the haproxy.cfg file we pushed out
  - haproxy service will fail on nodes as the expected Pod IP addresses fail
    - sudo journalctl -xeu haproxy.service
  - you will need to update the haproxy.cfg files and restart haproxy every time there is a change to the pods!

## Learn More
### HAProxy and its many uses
HAProxy is not just for container computing. Read more about it:
- https://medium.com/@gsatyasai2008/the-basics-of-haproxy-554c26992836
- https://www.udemy.com/course/haproxy-a/ (Udemy)
