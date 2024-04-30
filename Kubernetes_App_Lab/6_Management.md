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
## Replace Deployment
## Kubernetes Dashboard
## Learn More

