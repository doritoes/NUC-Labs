data "xenorchestra_template" "workstation-template" {
  name_label = "win11-template"
}
data "xenorchestra_network" "lan" {
  name_label = "Pool-wide network associated with eth0"
}

resource "xenorchestra_vm" "management-workstation" {
  memory_max = 4294934528
  cpus       = 2
  name_label = "manager"
  hvm_boot_firmware = "uefi"
  name_description = "Windows 11 mangagement workstation"
  template = data.xenorchestra_template.workstation-template.id
  depends_on = [ xenorchestra_network.network_management1]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "management-disk"
    size       = 137438953472
  }
  network {
    network_id = data.xenorchestra_network.lan.id
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}

resource "xenorchestra_vm" "branch1-1" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "branch1-1"
  hvm_boot_firmware = "uefi"
  name_description = "Windows 11 workstation 1 in branch 1"
  template = data.xenorchestra_template.workstation-template.id
  depends_on = [ xenorchestra_network.network_branch1]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "workstation-1-1-disk"
    size       = 137438953472
  }
  network {
    network_id = data.xenorchestra_network.branch1.id
  }
}
resource "xenorchestra_vm" "branch2-1" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "branch2-1"
  hvm_boot_firmware = "uefi"
  name_description = "Windows 11 workstation 1 in branch 2"
  template = data.xenorchestra_template.workstation-template.id
  depends_on = [ xenorchestra_network.network_branch2]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "workstation-2-1-disk"
    size       = 137438953472
  }
  network {
    network_id = data.xenorchestra_network.branch2.id
  }
}
resource "xenorchestra_vm" "branch3-1" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "branch3-1"
  hvm_boot_firmware = "uefi"
  name_description = "Windows 11 workstation 1 in branch 3"
  template = data.xenorchestra_template.workstation-template.id
  depends_on = [ xenorchestra_network.network_branch3]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "workstation-3-1-disk"
    size       = 137438953472
  }
  network {
    network_id = data.xenorchestra_network.branch3.id
  }
}
