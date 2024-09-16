data "xenorchestra_network" "branch1" {
  name_label = "branch1"
  depends_on = [xenorchestra_network.network_branch1]
}
data "xenorchestra_network" "branch2" {
  name_label = "branch2"
  depends_on = [xenorchestra_network.network_branch2]
}
data "xenorchestra_network" "branch3" {
  name_label = "branch3"
  depends_on = [xenorchestra_network.network_branch3]
}
data "xenorchestra_network" "branch1dmz" {
  name_label = "branch1dmz"
  depends_on = [xenorchestra_network.network_dmz1]
}
data "xenorchestra_network" "branch1mgt" {
  name_label = "branch1mgt"
  depends_on = [xenorchestra_network.network_management1]
}
data "xenorchestra_network" "branch1sync" {
  name_label = "branch1sync"
  depends_on = [xenorchestra_network.network_sync1]
}
data "xenorchestra_network" "branch2sync" {
  name_label = "branch2sync"
  depends_on = [xenorchestra_network.network_sync2]
}
data "xenorchestra_network" "branch3sync" {
  name_label = "branch3sync"
  depends_on = [xenorchestra_network.network_sync3]
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
  auto_poweron = false
  depends_on = [xenorchestra_network.network_isp1, xenorchestra_network.network_branch1, xenorchestra_network.network_dmz1, xenorchestra_network.network_management1, xenorchestra_network.network_sync1]
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
    network_id = data.xenorchestra_network.branch1sync.id
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
  auto_poweron = false
  depends_on = [xenorchestra_network.network_isp1, xenorchestra_network.network_branch1, xenorchestra_network.network_dmz1, xenorchestra_network.network_management1, xenorchestra_network.network_sync1]  
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
    network_id = data.xenorchestra_network.branch1sync.id
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
  auto_poweron = false
  depends_on = [xenorchestra_network.network_isp2, xenorchestra_network.network_branch2, xenorchestra_network.network_sync2]
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
  network {
    network_id = data.xenorchestra_network.branch2sync.id
  }
}

resource "xenorchestra_vm" "firewall2b" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall2b"
  name_description = "Check Point firewall branch 2 B"
  template = data.xenorchestra_template.firewall-template.id
  auto_poweron = false
  depends_on = [xenorchestra_network.network_isp2, xenorchestra_network.network_branch2, xenorchestra_network.network_sync2]
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
  network {
    network_id = data.xenorchestra_network.branch2sync.id
  }
}

resource "xenorchestra_vm" "firewall3a" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall3a"
  name_description = "Check Point firewall branch 3 A"
  template = data.xenorchestra_template.firewall-template.id
  auto_poweron = false
  depends_on = [xenorchestra_network.network_isp3, xenorchestra_network.network_branch3, xenorchestra_network.network_sync3]
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
  network {
    network_id = data.xenorchestra_network.branch3sync.id
  }
}

resource "xenorchestra_vm" "firewall3b" {
  memory_max = 4294934528
  cpus       = 4
  name_label = "firewall3b"
  name_description = "Check Point firewall branch 3 B"
  template = data.xenorchestra_template.firewall-template.id
  auto_poweron = false
  depends_on = [xenorchestra_network.network_isp3, xenorchestra_network.network_branch3, xenorchestra_network.network_sync3]
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
  network {
    network_id = data.xenorchestra_network.branch3sync.id
  }
}

resource "xenorchestra_vm" "sms" {
  memory_max = 8589869056
  cpus       = 4
  name_label = "sms"
  name_description = "Check Point SMS"
  template = data.xenorchestra_template.firewall-template.id
  depends_on = [xenorchestra_network.network_management1]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "sms-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1mgt.id
  }
}
