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
    - Complete Token ID: terraform@pam!terraform_token_id 
    - Make sure you copy down the Token Secret, as it will only be displayed once
  - Other less secure option is to create a token for user root and <ins>unselect</ins> privilege separation, as this grants root permissions
- Click Permissions
  - Click Add > User Permission three times
    - First
      - Path: /
      - User: terraform@pam
      - Role: PVEVMAdmin
      - Role: PVEAdmin
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
- Get the ssh_key from: `cat ~/.ssh/id_rsa.pub`
- mkdir ~/automation
- cd ~/automation
- create provider.tf from (provider.tf)[provider.tf]
~~~
terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = ">= 2.9.3"
    }
  }
}

variable "proxmox_api_url" {
  type = string
}
variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}
variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}
provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true
}
~~~
- create credentials.auto.tfvars from (credentials.auto.tfvars)[credentials.auto.tfvars]
~~~
proxmox_api_url = "https://192.168.99.205:8006/api2/json"
proxmox_api_token_id = "terraform@pam!terraform_token_id"
proxmox_api_token_secret = "4fd84501-9c3c-48bf-92ce-xxxxxxxxxxxxx"
~~~
- create server-1-clone.tf
~~~
resource "proxmox_vm_qemu" "server-1-clone" {
  name = "server-1-clone"
  desc = "ubuntu server"
  target_node = "labhost2"
  agent = 1
  clone = "template_ubuntu_server"
  sockets = 1
  cores = 2
  cpu = "host"
  memory = 2048
  network {
    bridge = "vmbr1"
    model = "virtio"
  }
}
~~~
- terraform init
- terraform plan
  - terraform plan -out tf.plan
- terraform apply --auto-approve
  - terraform apply tf.plan
- 
