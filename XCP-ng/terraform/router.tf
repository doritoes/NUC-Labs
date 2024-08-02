# Cannot "Other install media"

data "xenorchestra_network" "wan" {
  name_label = "Pool-wide network associated with eth0"
}
data "xenorchestra_network" "build" {
  name_label = "build"
  depends_on = [xenorchestra_network.vlan_network_100]
}

data "xenorchestra_template" "template" {
  name_label = "Other install media"
}

data "xenorchestra_sr" "local" {
  name_label = "Local storage"
}

data "xenorchestra_sr" "ISO" {
  name_label = "ISO"
}

data "xenorchestra_vdi" "vyos_rolling" {
  name_label = "vyos-1.5-rolling-202407010024-amd64.iso"
}

resource "xenorchestra_vm" "vyos" {
  memory_max = 1073733632
  cpus       = 2
  #cloud_config  =
  name_label = "vyos"
  name_description = "vyos router"
  template = data.xenorchestra_template.template.id
  cdrom {
    id = data.xenorchestra_vdi.vyos_rolling.id
  }
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
}
