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
# VLAN 110 ISP1 network
resource "xenorchestra_network" "vlan_network_110" {
  name_label = "isp1"
  name_description = "isp1 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 110
}
# VLAN 120 ISP2 network
resource "xenorchestra_network" "vlan_network_120" {
  name_label = "isp2"
  name_description = "isp2 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 120
}
# VLAN 130 ISP3 network
resource "xenorchestra_network" "vlan_network_130" {
  name_label = "isp3"
  name_description = "isp3 emulated network"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 130
}
# VLAN 210 Branch1 network
resource "xenorchestra_network" "vlan_network_210" {
  name_label = "branch1"
  name_description = "Branch 1 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 210
}
# VLAN 220 Branch2 network
resource "xenorchestra_network" "vlan_network_220" {
  name_label = "branch2"
  name_description = "Branch 2 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 220
}
# VLAN 230 Branch3 network
resource "xenorchestra_network" "vlan_network_230" {
  name_label = "branch3"
  name_description = "Branch 3 LAN"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 230
}
# VLAN 310 Branch1 DMZ
resource "xenorchestra_network" "vlan_network_310" {
  name_label = "branch1dmz"
  name_description = "Branch 1 DMZ"
  pool_id = data.xenorchestra_host.host1.pool_id
  source_pif_device = "eth0"
  vlan = 310
}
