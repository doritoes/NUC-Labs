# Advanced Automation with proxymox.
Proxmox does not ship with Ansible, but you can install it on the host. This example is based on the example by [fatzombi](https://medium.com/@fat_zombi).

Terraform is an open-source infrastructure as code tool that allows you to define and manage your infrastructure as code. This code is a declarative language that is simple to write. In this Labwe will use Terraform to automate the creation of VMs in Proxmox.

TIP: Support fatzombi [here](https://www.buymeacoffee.com/fatzombi)

Reference: https://www.reddit.com/r/homelab/comments/13u66yn/automating_your_homelab_with_proxmox_cloudinit/
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-introduction-6a95ee3e57a
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-part-1-configuring-a-448576621edd?sk=efe413d550cc0cac162463b804e18577
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-part-2-deploying-your-a7de6caa64b7?sk=ef40743f7886f50cc1f121d818605c22
- https://medium.com/@fat_zombi/automating-your-homelab-with-proxmox-cloud-init-terraform-and-ansible-part-3-automating-with-23acc2343340?sk=3f7023f29dc560b41bd97f3221e08c0b

NOTES
- This lab is performned on the proxmox host itself
- You will need a subscription or have installed the no-subscription repository

# Create API Users, Permissions and Tokens
Terraform needs users, permissions, and tokens in order to interact with proxmox.
- Log in to proxmox
- Click Datacenter
- Click Permissions > Users
- Click Add
  - Username: terrform
  - Realm: Linux Pam standard authentication
  - Enabled: Yes
  - Click Add 
- Click Permissions > API Tokens
  - Click Add
    - User: **terraform@pam**
    - Privilege Separation: **checked**
    - Token ID: **terraform_token_id**
    - As you’ll be warned, make sure you copy down the Token Secret, as it will only be displayed once.
- Click Permissions
  - Click Add > User Permission three times
    - First
      - Path: /
      - User: terraform@pam
      - Role: PVEVMAdmin
    - Second
      - Path: /storage/local
      - User: terraform@pam
      - Role: Administrator
    - Third
      - Path: /storage/local-kvm
      - User: terraform@pam
      - Role: Administrator

# Install Terraform
It's not in the official repos for Debian, so we’ll add a new repository and install it onto Proxmox.

~~~
apt install lsb-release
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" >> /etc/apt/sources.list.d/terraform.list
apt update && apt install terraform
terraform -v
~~~

# Configure Terraform project
~~~
mkdir terraform-lab
cd terraform-lab
touch main.tf
touch vars.tf
touch pihole.tf
touch homebridge.tf
~~~
# Deploy VMs
- terraform init
- terraform plan
- terraform apply
