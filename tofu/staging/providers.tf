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
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.3"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox.endpoint
  insecure  = var.proxmox.insecure
  api_token = var.proxmox.api_token

  ssh {
    agent       = false
    username    = var.proxmox.username
    private_key = var.proxmox.private_key
  }
}

provider "restapi" {
  uri                  = var.proxmox.endpoint
  insecure             = var.proxmox.insecure
  write_returns_object = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "PVEAPIToken=${var.proxmox.api_token}"
  }
}
