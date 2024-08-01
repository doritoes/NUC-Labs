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

## Create Files
- Create project directory
  - `mkdir ~/terraform`
  - `cd ~/terraform`
- Create file provider.tf from [provider.tf](provider.tf)
- Create file credentials.auto.tfvars from [credentials.auto.tfvars](credentials.auto.tfvars)
  - Modify to use your XCP-ng host IP address
  - Modify to use a valid username and password
- Test
  - `terraform init`
  - `terraform plan`
  - `terraform apply`

## Next step
