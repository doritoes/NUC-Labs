# Advanced Automation with proxymox
Terraform is an open-source infrastructure as code tool that allows you to define and manage your infrastructure as code. This code is a declarative language that is simple to write. In this Lab we will use Terraform to automate the creation of VMs in Proxmox.

Proxmox does not ship with Ansible, but you can install it on the host. This will enable further management of the VMs.

IMPORTANT proxmox and Terraform have a LOT of gotchas and you will run into a lot of issues trying to use it in production (see https://github.com/Telmate/terraform-provider-proxmox/issues)

NOTES
- This lab is performned on the proxmox host itself
- You will need a subscription or have installed the no-subscription repository
- You have already created a template named **ubuntu-server-lan**, created from a VM you built earlier

# Create API Users, Permissions and Tokens
Terraform needs users, permissions, and tokens in order to interact with proxmox.

Command line:
~~~
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt VM.GuestAgent.Audit"
pveum user add terraform-prov@pve --password strongpassword
pveum aclmod / -user terraform-prov@pve -role TerraformProv
pveum user token add terraform-prov@pve terraform-token --privsep=0
~~~
NOTE proxmox 9 has removed VM.Monitor. Sys.Audit is relied on instead.

- Complete Token ID: terraform-prov@pve!terrform-token
- Make sure you copy down the Token Secret, as it will only be displayed once
- Other less secure option is to create a token for user root and <ins>unselect</ins> privilege separation, as this grants root permissions
- Datacenter > Permissions
- Click Add > User Permission
  - Path: /sdn/zones/localnetork
  - User: terraform-prov
  - Role: Administrator

# Install Terraform
https://developer.hashicorp.com/terraform/install

It's not in the official repos for Debian, so add a new repository and install it onto the proxmox host. Note that these commands are tuned for this installation, run as `root`.
~~~
apt install lsb-release
wget -O - -q https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y terraform
terrform version
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
- Test the VMs
- When done, `terraform destroy`

Error: The terraform-provider-proxmox_v2.9.14 plugin crashed! This is a known issue that is fixed in version 3RC3.

Problems:
 - cloning to 40G works, but the volume is still 20GB, unused disk space
   - `fdisk -l`
   - GPT PMBR size mismatch (4194309 != 83886079) will be corrected by write.
   - The backup GPT table is not at the end of the device
   - run `sudo parted -l` and respond "fix"
   - `fdisk -l`

