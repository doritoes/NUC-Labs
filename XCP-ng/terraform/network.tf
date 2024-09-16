data "xenorchestra_host" "host1" {
  name_label = "${var.xo_pool}"
}

resource "xenorchestra_network" "network_build" {
  name_label = "build"
  name_description = "build network off router"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_isp1" {
  name_label = "isp1"
  name_description = "isp1 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_isp2" {
  name_label = "isp2"
  name_description = "isp2 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_isp3" {
  name_label = "isp3"
  name_description = "isp3 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_branch1" {
  name_label = "branch1"
  name_description = "Branch 1 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_branch2" {
  name_label = "branch2"
  name_description = "Branch 2 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_branch3" {
  name_label = "branch3"
  name_description = "Branch 3 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_dmz1" {
  name_label = "branch1dmz"
  name_description = "Branch 1 DMZ"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_management1" {
  name_label = "branch1mgt"
  name_description = "Branch 1 Management"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_sync1" {
  name_label = "branch1sync"
  name_description = "Branch 1 Sync"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_sync2" {
  name_label = "branch2sync"
  name_description = "Branch 2 Sync"
  pool_id = data.xenorchestra_host.host1.pool_id
}
resource "xenorchestra_network" "network_sync3" {
  name_label = "branch3sync"
  name_description = "Branch 3 Sync"
  pool_id = data.xenorchestra_host.host1.pool_id
}
