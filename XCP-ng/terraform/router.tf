data "xenorchestra_network" "wan" {
  name_label = "Pool-wide network associated with eth0"
}
data "xenorchestra_network" "build" {
  name_label = "build"
  depends_on = [xenorchestra_network.vlan_network_100]
}
data "xenorchestra_network" "isp1" {
  name_label = "isp1"
  depends_on = [xenorchestra_network.vlan_network_110]
}
data "xenorchestra_network" "isp2" {
  name_label = "isp2"
  depends_on = [xenorchestra_network.vlan_network_120]
}
data "xenorchestra_network" "isp3" {
  name_label = "isp3"
  depends_on = [xenorchestra_network.vlan_network_130]
}

data "xenorchestra_template" "template" {
  name_label = "vyos-template"
}

data "xenorchestra_sr" "local" {
  name_label = "Local storage"
}

resource "xenorchestra_vm" "vyos" {
  memory_max = 1073733632
  cpus       = 2
  #cloud_config  =
  name_label = "vyos"
  name_description = "vyos router"
  template = data.xenorchestra_template.template.id
  disk {
    sr_id      = data.xenorchestra_sr.local.id
    name_label = "vyos-router-disk"
    size       = 8589869056
  }
  network {
    network_id = data.xenorchestra_network.wan.id
  }
  network {
    network_id = data.xenorchestra_network.build.id
  }
  network {
    network_id = data.xenorchestra_network.isp1.id
  }
  network {
    network_id = data.xenorchestra_network.isp2.id
  }
  network {
    network_id = data.xenorchestra_network.isp3.id
  }
}
