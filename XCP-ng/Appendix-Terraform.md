# Appendix - Terraform and XCP-ng
References: https://github.com/vatesfr/terraform-provider-xenorchestra

Notes:
- Terraform integrates with the XO server, not the XCP-ng host

## Install Terrafrom
- Install prerequisites
  - `sudo apt-get update && sudo apt-get install -y lsb-release gnupg software-properties-common`
- Quick install
~~~
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee -a  /etc/apt/sources.list.d/terraform.list
sudo apt update && sudo apt install -y terraform
~~~
- Confirm
  - `terraform -v`

## Set up Project
- Create project directory
  - `mkdir ~/terraform`
  - `cd ~/terraform`
- Create file provider.tf from [provider.tf](terraform/provider.tf)
- Create file credentials.auto.tfvars from [credentials.auto.tfvars](terraform/credentials.auto.tfvars)
  - Modify to use your XCP-ng host IP address
  - Modify to use a valid username and password
- Create file demo.tf from [demo.tf](terraform/demo.tf)
- Test
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
- The output shows
  - number of VMs that are running (vms_length)
  - sum of all running VMs' max memory in bytes (vms_max_memory_map)

## Create VyOS Template
- Log in to XO and create a VyOS router
- From left menu **New** > **VM**
  - Pool: **xcp-ng-lab1**
  - Template: **Ohter install media**
  - Name: **vyos-template**
  - Description: **vyos-template**
  - CPU: **2 vCPU**
  - RAM: **1GB**
  - Topology: **Default behavior**
  - Install: ISO/DVD: *Select the VyOS ISO image you uploaded earlier*
  - Interfaces:
    - First interface: *Pool-wide network associated with eth0*
  - Disks: Click Add disk
    - **8GB**
  - Click **Create**
- Open Console
- Install the Image
  - Login: `vyos`/`vyos`
  - `install image`
  - Allow installation to continue with default values
  - When you are asked to set the password just use `vyos`
  - When promted, `reboot`
  - After the reboot starts, eject the VyOS iso
- Enable guest utilties
  - Log back in
    - `sudo systemctl start xe-guest-utilities`
    - `sudo systemctl enable xe-guest-utilties`
    - `poweroff`
- Convert to Template
  - Click the Advanced tab
  - Click Convert to template and confirm that this can't be undone

## Network Configuration
- Create file network.tf from [network.tf](terraform/network.tf)
- `terraform init`
- `terraform plan`
- `terraform apply -auto-approve'
- Log in to XO and confirm the new neworks are created
- Destroy and re-create
  - `terraform destroy`
  - `terraform apply -auto-approve`

## Create VyOS Router with Terraform
