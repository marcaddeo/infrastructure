provider "proxmox" {
  endpoint = "https://crimson.addeo.net:8006/"
  # because self-signed TLS certificate is in use
  insecure = true
  tmp_dir  = "/var/tmp"

  ssh {
    agent       = false
    username    = "ansible"
    private_key = file("../ansible/host_keys/id_rsa.ansible@addeo.net")
  }
}

resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name        = "talos-cp-01"
  vm_id       = 200
  description = "Managed by Tofu"

  node_name = "crimson"

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 8
    type  = "host"
  }

  memory {
    dedicated = 8096
    floating  = 8096 # set equal to dedicated to enable ballooning
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "vmpool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    vlan_id = 115
  }

  initialization {
    datastore_id = "vmpool"

    ip_config {
      ipv4 {
        address = "${var.talos_cp_01_ip_addr}/24"
        gateway = var.default_gateway
      }

      ipv6 {
        address = "dhcp"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  depends_on = [proxmox_virtual_environment_vm.talos_cp_01]

  name        = "talos-worker-01"
  vm_id       = 201
  description = "Managed by Tofu"

  node_name = "crimson"

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8048
    floating  = 8048 # set equal to dedicated to enable ballooning
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "vmpool"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    vlan_id = 115
  }

  initialization {
    datastore_id = "vmpool"

    ip_config {
      ipv4 {
        address = "${var.talos_worker_01_ip_addr}/24"
        gateway = var.default_gateway
      }

      ipv6 {
        address = "dhcp"
      }
    }
  }
}
