data "xenorchestra_template" "workstation-template" {
  name_label = "win10-template"
}
data "xenorchestra_network" "lan" {
  name_label = "Pool-wide network associated with eth0"
}

resource "xenorchestra_vm" "management-workstation" {
  memory_max = 4294934528
  cpus       = 2
  name_label = "manager"
  name_description = "Windows 10 mangagement workstation"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [ xenorchestra_network.vlan_network_401]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "management-disk"
    size       = 137437904896
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
  name_description = "Windows 10 workstation 1 in branch 1"
  template = data.xenorchestra_template.workstation-template.id
  depends_on = [ xenorchestra_network.vlan_network_201]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "workstation-1-1-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}
resource "xenorchestra_vm" "branch2-1" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "branch2-1"
  name_description = "Windows 10 workstation 1 in branch 2"
  template = data.xenorchestra_template.workstation-template.id
  depends_on = [ xenorchestra_network.vlan_network_202]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "workstation-1-1-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}
resource "xenorchestra_vm" "branch3-1" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "branch3-1"
  name_description = "Windows 10 workstation 1 in branch 3"
  template = data.xenorchestra_template.workstation-template.id
  depends_on = [ xenorchestra_network.vlan_network_203]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "workstation-3-1-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}
