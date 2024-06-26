# Management
In this step we look at deploying different application images
- doritoes/k8s-php-demo-app:blue
- doritoes/k8s-php-demo-app:green
- doritoes/k8s-php-demo-app:orange

Strategies supported by Kubernetes out of the box:
- rolling deployment (default) - replaces pods running the older version with the new version one-by-one
- recreate deployment - terminates all pods and replaces them with the new version
 - ramped slow rollout - very safe and slow rollout
- best-effort controlled rollout - fast and lower overhead but run during a maintenance window

Strategies that requires customization or specialized tools:
- blue/green deployment
- canary deployment
- shadow deployment
- A/B testing

References:
- https://spot.io/resources/kubernetes-autoscaling/5-kubernetes-deployment-strategies-roll-out-like-the-pros/

## Rolling Deployment
Open a second terminal or ssh session.  You will watch the status of your deployment here.
- `watch -d -n 1 'kubectl get pods,deploy'`

### Update the Image in k8s-deployment-web.yml
- edit `k8s-deployment-web.yml`
  - modify `image`  to use the new image tag
    - `image: doritoes/k8s-php-demo-app:green`

### Kick Off the Update
This process will perform a one-by-one replacement. Health checks (liveness and readiness) ensure new pods are healthy before taking old ones offline.

#### Option 1 - Run Ansible playbook
`ansible-playbook deploy-web.yml`

#### Option 2 - Apply Kubernetes manifest
`kubectl apply -f k8s-deployment-web.yml`

#### Observe the Rollout
Observe the rollout status:
- `kubectl rollout status deployment/web-deployment`

Watch the status in the other session.
- What can you see happening?
- What useful information is missing?

Examine the deployment and see which image is running:
- `kubectl describe deployment/web-deployment`

Here are two ways to get the images running on all pods:
- `kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort`

### Testing and Troubleshooting
Load the web app now (either by nodePort or by updating the HAProxy config)
- You may need to press F5 or Control F5 to refresh the style-sheet
- The color of the app should now be green

If the rollout is stalled, use these commands to investigate potential issues:
- `kubectl describe deployment web-deployment`
- `kubectl get pods`
- `kubectl logs <pod-name>`

### Rollback
Roll back the update:
- `kubectl rollout undo deployment/web-deployment`

Observe the rollback:
- `kubectl rollout status deployment/web-deployment`
- Watch the status in the other session

Examine the deployment and see which image is running:
- `kubectl describe deployment/web-deployment`
- load the web app again and Control-F5/reload to refresh the CSS formatting
- the color should be back to blue

## Improvements
You can customize the rolling deployment behavior within your Deployment spec with the `maxSurge` and `maxUnavailable` properties.

For example here is adding the ability to add up to 25% of the desired number of pods and ensuring you never drop before the desired number of pods.

~~~~
spec:
  replicas: 2 
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%  # Can exceed the desired number of pods
      maxUnavailable: 0  # No downtime during the update 
  # ... rest of your deployment specification ...
~~~~

## Replace Deployment
This is the ungraceful method to kill all pods and re-create them with no concern as to update. We will deploy the "orange" image this time.

If it is not still running, restart the second session watching the pods and deployment:
- `watch -d -n 1 'kubectl get pods,deploy'`

### Update Deploy Strategy
- Create `k8s-replace-web.yml` from [k8s-replace-web.yml](k8s-replace-web.yml)
  - Optionally, you could just modify `k8s-deployment-web.yml` to add a section:
    - `strategy:`
    - `  type: Recreate`
    - modify `image`  to use the new image tag
    - `image: doritoes/k8s-php-demo-app:orange`

### Kick Off the Update
`kubectl apply -f k8s-deployment-web.yml`

#### Observe the Rollout
Observe the rollout status:
- `kubectl rollout status deployment/web-deployment`

After it's done, examine the image that is running.
- `kubectl describe deployment/web-deployment`

### Testing and Troubleshooting
Load the web app now (either by nodePort or by updating the HAProxy config)
- You may need to press F5 or Control F5 to refresh the style sheet-
- The color of the app should now be orange

### Rollback
Roll back the update:
- `kubectl rollout undo deployment/web-deployment`

Observe the rollback:
- `kubectl rollout status deployment/web-deployment`
- Watch the status in the other session
- What method is used for the rollback?
- View the rollout history
  - `kubectl rollout history deployment/web-deployment`
  - Is this history empty? What changed each time you rolled back?

Examine the deployment and see which image is running:
- `kubectl describe deployment/web-deployment`
- Load the web app again and Control-F5/reload to refresh the CSS formatting.
- The color should be back to blue

Try updating `k8s-deployment-web.yml` to update the image:
- `doritoes/k8s-php-demo-app:blue`
- `doritoes/k8s-php-demo-app:green`
- `doritoes/k8s-php-demo-app`
- `doritoes/k8s-php-demo-app:orange`
- `doritoes/k8s-php-demo-app:latest`
- Each time apply using `ansible-playbook deploy-web.yml`

View the rollout history:
- `kubectl rollout history deployment/web-deployment`

Pick a revision number and view the details:
- `kubectl rollout history deployment/web-deployment --revision=<revision-number>`

NOTE on Revision numbering. The reason your revision numbers seem out of order could be due to a few factors:
- Rollbacks: If you performed rollbacks using kubectl rollout undo, the rolled-back version gets assigned a new, higher revision number.
- Manual Manifest Change: Manually editing the deployment's pod template using kubectl edit also generates a new revision
- Failed Deployments: Sometimes, if the deployment process fails, a new revision could be created even if no new pods were successfully launched

## Kubernetes Dashboard
The Kubernetes Dashboard is a web-based graphical user interface (GUI) built into Kubernetes. This provides a comprehensive overview of the cluster and facilitates basic tasks.

### Install
Deploy the dashboard
- `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml`

### Create Service Account
Create a service account and bind the `cluster-admin` role to it
- `kubectl create serviceaccount dashboard -n kubernetes-dashboard`
- `kubectl create clusterrolebinding dashboard-admin -n kubernetes-dashboard  --clusterrole=cluster-admin  --serviceaccount=kubernetes-dashboard:dashboard`

### Create Token
`kubectl -n kubernetes-dashboard create token dashboard`

You will use this token in a moment.

### Launch the Dashboard
UI can <ins>only be accessed from the machine where the command is executed</ins>
- `kubectl proxy`
- Browse to: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
- Authenticate with “Token” and paste in the token from the previous step
- This is not at full-featured as using kubectl, but simplify things for you
- Try deleting pods and watch them get deployed

## Learn More
### Ramped Slow Rollout
This strategy gradually updates pods, ensuring consistent availability, and offers granular control over rollout speed.

**How it works:** New replicas are created while old ones are removed. You directly control the number of pods updated simultaneously.

**Key difference:** Compared to a standard rolling deployment, you precisely manage the update pace, minimizing risks by updating only a few pods at a time (e.g., 1 or 2).

Configuration:
- maxSurge: 1 Allows only one pod to be added beyond the desired count during the update
- maxUnavailable: 0 Ensures zero downtime; no pods are taken offline before new ones are ready

Example: For a 10-pod deployment, this setup guarantees at least 10 pods are always available throughout the update process.

### Best Effort Controlled Rollout
This strategy prioritizes update speed over the zero-downtime guarantee of a ramped rollout. It introduces some risk by allowing a configurable percentage of pods to be temporarily unavailable.

**How it works:** Rapidly replaces pods as quickly as possible, while ensuring that the downtime stays within a specified limit.

**Tradeoff:** Offers faster rollout in exchange for some potential downtime. Choose this if time-to-new-features is paramount and your app can handle the defined downtime tolerance

Configuration:
- maxSurge: 0 A Maintains a constant number of pods, optimizing resource usage during the update
- maxUnavailable: 20% A percentage defining the acceptable number of unavailable pods during the update

### Blue-Green Deployments
The purpose of Blue-Green deployments are:
- No Downtime: aims to eliminate downtime for updates
- Testing in Production: 'green' enables real-world testing before exposing users (A/B testing)
- Beyond Simple Rollouts: introduces the idea of traffic management strategies, contrasting it with basic rolling updates

To do a proper blue-green deployment you need to account for
- separate clusters
- database mirroring

