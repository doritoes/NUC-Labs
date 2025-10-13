resource "proxmox_vm_qemu" "server-clone" {
  # VM general settings
  count = 2 # number of VMs to create
  target_node = "proxmox-lab"
  name = "server-clone-${count.index + 1}"
  description = "ubuntu server"
  # onboot = true

  # Clone VM operation
  clone = "ubuntu-server-lan"
  # note that cores, sockets, and memory settings not copied form source VM template
  cpu {
    cores = 1
    sockets = 1
    type = "host"
  }
  memory = 2048

  # Activate QEMU agent
  agent = 1

  # Network settings
  network {
    id = 0
    bridge = "vmbr1"
    model = "virtio"
  }
}
