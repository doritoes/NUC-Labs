data "xenorchestra_network" "branch1" {
  name_label = "branch1"
  depends_on = [xenorchestra_network.vlan_network_201]
}
data "xenorchestra_network" "branch2" {
  name_label = "branch2"
  depends_on = [xenorchestra_network.vlan_network_202]
}
data "xenorchestra_network" "branch3" {
  name_label = "branch3"
  depends_on = [xenorchestra_network.vlan_network_203]
}
data "xenorchestra_network" "branch1dmz" {
  name_label = "branch1dmz"
  depends_on = [xenorchestra_network.vlan_network_301]
}
data "xenorchestra_network" "branch1mgt" {
  name_label = "branch1mgt"
  depends_on = [xenorchestra_network.vlan_network_401]
}

data "xenorchestra_template" "firewall-template" {
  name_label = "checkpoint-template"
}

resource "xenorchestra_vm" "firewall1a" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall1a"
  name_description = "Check Point firewall branch 1 A"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.vlan_network_101, xenorchestra_network.vlan_network_201, xenorchestra_network.vlan_network_301, xenorchestra_network.vlan_network_401]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "cpfw-1a-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.isp1.id
  }
  network {
    network_id = data.xenorchestra_network.branch1dmz.id
  }
  network {
    network_id = data.xenorchestra_network.branch1.id
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}

resource "xenorchestra_vm" "firewall1b" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall1b"
  name_description = "Check Point firewall branch 1 B"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.vlan_network_101, xenorchestra_network.vlan_network_201, xenorchestra_network.vlan_network_301, xenorchestra_network.vlan_network_401]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "cpfw-1b-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.isp1.id
  }
  network {
    network_id = data.xenorchestra_network.branch1dmz.id
  }
  network {
    network_id = data.xenorchestra_network.branch1.id
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}

resource "xenorchestra_vm" "firewall2a" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall2a"
  name_description = "Check Point firewall branch 2 A"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.vlan_network_102, xenorchestra_network.vlan_network_202]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "cpfw-2a-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.isp2.id
  }
  network {
    network_id = data.xenorchestra_network.branch2.id
  }
}

resource "xenorchestra_vm" "firewall2b" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall2b"
  name_description = "Check Point firewall branch 2 B"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.vlan_network_102, xenorchestra_network.vlan_network_202]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "cpfw-2b-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.isp2.id
  }
  network {
    network_id = data.xenorchestra_network.branch2.id
  }
}

resource "xenorchestra_vm" "firewall3a" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall3a"
  name_description = "Check Point firewall branch 3 A"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.vlan_network_103, xenorchestra_network.vlan_network_203]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "cpfw-3a-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.isp3.id
  }
  network {
    network_id = data.xenorchestra_network.branch3.id
  }
}

resource "xenorchestra_vm" "firewall3b" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall3b"
  name_description = "Check Point firewall branch 3 B"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.vlan_network_103, xenorchestra_network.vlan_network_203]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "cpfw-3b-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.isp3.id
  }
  network {
    network_id = data.xenorchestra_network.branch3.id
  }
}

resource "xenorchestra_vm" "sms" {
  memory_max = 8589869056
  cpus       = 4
  name_label = "sms"
  name_description = "Check Point SMS"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.vlan_network_401]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "sms-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}
