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
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
  }
}

provider "proxmox" {
  endpoint  = local.proxmox.endpoint
  insecure  = local.proxmox.insecure
  api_token = local.proxmox.api_token

  ssh {
    agent       = false
    username    = local.proxmox.username
    private_key = local.proxmox.private_key
  }
}

provider "restapi" {
  alias                = "proxmox"
  uri                  = local.proxmox.endpoint
  insecure             = local.proxmox.insecure
  write_returns_object = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "PVEAPIToken=${local.proxmox.api_token}"
  }
}

provider "restapi" {
  alias                = "rancher"
  uri                  = local.rancher.endpoint
  insecure             = local.rancher.insecure
  write_returns_object = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${local.rancher.api_token}"
  }
}
