resource "proxmox_vm_qemu" "server-clone" {
  # VM general settings
  target_node = "proxmox-lab"
  vmid = "409"
  name = "server-clone"
  desc = "ubuntu server"

  # onboot = true

  # VM OS Settings
  clone = "template_ubuntu_server"

  # VM System Settings
  agent = 1

  # VM CPU Settings
  cores = 2
  sockets = 1
  cpu = "host"

  # VM Memory Settings
  memory = 2048

  # VM Network Settings
  network {
    bridge = "vmbr1"
    model = "virtio"
  }
}
