# Cleanup and Next Steps
Congratulation on reaching the end of this Lab!

Along the way we have covered
1. Installing Ubuntu Desktop using a USB stick
2. Installing Ubuntu Server using the autoinstall method from USB sticks
3. Managing servers using Ansible playbooks
4. Installing a complex service-based application (FAH) using Ansible
5. Installing a distributed hash cracking cluster using Ansible
6. Installing a Kubernetes cluster using Ansible

Right now you have a stack of NUCs managed using Ansible. What will you do with them? I recommend re-imaing the NUCs for a fresh environment to build your own Labs.

Here are some ideas of what to try next:
- Look at other NUC labs in this repo - https://github.com/doritoes/NUC-Labs/
- ML Models
  - deploy a machine learning model on NUC's as a ML-edge design; optionally on a Kubernetes cluster
  - https://www.analyticsvidhya.com/blog/2022/01/deploying-ml-models-using-kubernetes/
  - https://www.seldon.io/deploying-machine-learning-models-on-kubernetes\
- Experiment with Cobbler (provisioning, installation, and update server; supports deployments via PXE, virtualization and re-installs of existing Linux systems
  - https://github.com/cobbler/cobbler
  - https://cobbler.readthedocs.io/en/latest/
  - https://lamastex.github.io/scalable-data-science/sds/basics/infrastructure/onpremise/NUCcluster/
- Experiment with Proxmox on a NUC for virutalization and running Docker containers on it
  - https://www.youtube.com/watch?v=GMAvmHEWAMU
- Assembling the stack of NUCs together into a cluster - https://github.com/ryanyard/mini-cluster
