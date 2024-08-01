# Advanced Automation with proxymox
Terraform is an open-source infrastructure as code tool that allows you to define and manage your infrastructure as code. This code is a declarative language that is simple to write. In this Lab we will use Terraform to automate the creation of VMs in Proxmox.

Proxmox does not ship with Ansible, but you can install it on the host. This will enable further management of the VMs.

NOTES
- This lab is performned on the proxmox host itself
- You will need a subscription or have installed the no-subscription repository
- You have already created a template named **template-ubuntu-server**, created from a VM you built earlier

# Create API Users, Permissions and Tokens
Terraform needs users, permissions, and tokens in order to interact with proxmox.

Command line:
~~~
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
pveum user add terraform-prov@pve --password strongpassword
pveum aclmod / -user terraform-prov@pve -role TerraformProv
~~~

From proxmox Web GUI:
- Update the password for user **terrafrom-prov**
- Next, click **Permissions** > **API Tokens**
  - Click Add
    - User: **terraform-prov@pve**
    - Privilege Separation: **NOT checked**
    - Token ID: **terrform_token_id**
    - Complete Token ID: terraform-prov@pve!terrform_token_id
    - Make sure you copy down the Token Secret, as it will only be displayed once
  - Other less secure option is to create a token for user root and <ins>unselect</ins> privilege separation, as this grants root permissions

# Install Terraform
It's not in the official repos for Debian, so we’ll add a new repository and install it onto Proxmox.

~~~
apt install lsb-release
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" >> /etc/apt/sources.list.d/terraform.list
apt update && apt install -y terraform
terraform -v
~~~

# Configure Terraform project
References:
- https://github.com/ChristianLempa/boilerplates/tree/main/terraform/proxmox
- https://www.youtube.com/watch?v=1nf3WOEFq1Y
- https://www.youtube.com/watch?v=dvyeoDBUtsU

- If you are going to set the ssh_key
  - Get the ssh_key `cat ~/.ssh/id_rsa.pub`
- `mkdir ~/automation`
- `cd ~/automation`
- create provider.tf from [provider.tf](provider.tf)
- create credentials.auto.tfvars from (credentials.auto.tfvars)[credentials.auto.tfvars]
  - modify the URL to use the IP address of your proxmox host
  - modify the secret to the value you received earlier
- create server-clone.tf [server-clone.tf](server-clone.tf)
- `terraform init`
- `terraform plan`
  - Or, `terraform plan -out tf.plan`
- `terraform apply --auto-approve`
  - Or, `terraform apply tf.plan`

# Test
Open the new VM's console and verify the settings
