data "xenorchestra_template" "server2022-template" {
  name_label = "server2022-template"
}
data "xenorchestra_template" "server-ubuntu-template" {
  name_label = "ubuntu-server-template"
}

resource "xenorchestra_vm" "dmz-apache" {
  memory_max = 1073733632
  cpus       = 1
  name_label = "dmz-apache"
  name_description = "Ubuntu server in DMZ running Apache"
  template = data.xenorchestra_template.server-ubuntu-template.id
  depends_on = [ xenorchestra_network.network_dnz1]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "dmz-apache-disk"
    size       = 68718952448
  }
  network {
    network_id = data.xenorchestra_network.branch1dmz.id
  }
}

resource "xenorchestra_vm" "dmz-iis" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "dmz-iis"
  name_description = "Windows Server 2022 in DMZ running IIS"
  template = data.xenorchestra_template.server2022-template.id
  depends_on = [ xenorchestra_network.vlan_network_301]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "dmz-iis-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1dmz.id
  }
}

resource "xenorchestra_vm" "dc-1" {
  memory_max = 4294934528
  cpus       = 2
  name_label = "dc-1"
  name_description = "Domain Controller Branch 1"
  template = data.xenorchestra_template.server2022-template.id
  depends_on = [ xenorchestra_network.network_branch1]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "dc-1-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1.id
  }
}

resource "xenorchestra_vm" "file-1" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "file-1"
  name_description = "File Server Branch 1"
  template = data.xenorchestra_template.server2022-template.id
  depends_on = [ xenorchestra_network.network_branch1]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "file-1-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1.id
  }
}

resource "xenorchestra_vm" "sql-1" {
  memory_max = 4294934528
  cpus       = 1
  name_label = "sql-1"
  name_description = "SQL Server Branch 1"
  template = data.xenorchestra_template.server2022-template.id
  depends_on = [ xenorchestra_network.network_branch1]
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "sql-1-disk"
    size       = 137437904896
  }
  network {
    network_id = data.xenorchestra_network.branch1.id
  }
}
