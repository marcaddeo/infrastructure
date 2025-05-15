terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.77.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.8.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://crimson.addeo.net:8006/"
  # because self-signed TLS certificate is in use
  insecure = true
  tmp_dir  = "/var/tmp"

  ssh {
    agent       = false
    username    = "ansible"
    private_key = file("../../ansible/host_keys/id_rsa.ansible@addeo.net")
  }
}
