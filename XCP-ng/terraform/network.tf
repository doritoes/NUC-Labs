data "xenorchestra_host" "host1" {
  name_label = "${var.xo_pool}"
}

# VLAN 100 build network
resource "xenorchestra_network" "vlan_network_100" {
  name_label = "build"
  name_description = "build network off router"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 100
}
# VLAN 101 ISP1 network
resource "xenorchestra_network" "vlan_network_101" {
  name_label = "isp1"
  name_description = "isp1 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 101
}
# VLAN 102 ISP2 network
resource "xenorchestra_network" "vlan_network_102" {
  name_label = "isp2"
  name_description = "isp2 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 102
}
# VLAN 103 ISP3 network
resource "xenorchestra_network" "vlan_network_103" {
  name_label = "isp3"
  name_description = "isp3 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 103
}
# VLAN 201 Branch1 network
resource "xenorchestra_network" "vlan_network_201" {
  name_label = "branch1"
  name_description = "Branch 1 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 201
}
# VLAN 202 Branch2 network
resource "xenorchestra_network" "vlan_network_202" {
  name_label = "branch2"
  name_description = "Branch 2 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 202
}
# VLAN 203 Branch3 network
resource "xenorchestra_network" "vlan_network_203" {
  name_label = "branch3"
  name_description = "Branch 3 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 203
}
# VLAN 301 Branch1 DMZ
resource "xenorchestra_network" "vlan_network_301" {
  name_label = "branch1dmz"
  name_description = "Branch 1 DMZ"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 301
}
# VLAN 401 Branch1 Management
resource "xenorchestra_network" "vlan_network_401" {
  name_label = "branch1mgt"
  name_description = "Branch 1 Management"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 401
}
