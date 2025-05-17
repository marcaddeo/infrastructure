module "talos" {
  source = "../modules/talos"

  providers = {
    proxmox = proxmox
    talos   = talos
  }

  image = {
    version          = "v1.10.0"
    update_version   = "v1.10.1" # renovate: github-releases=siderolabs/talos
    schematic        = file("${path.module}/../modules/talos/image/schematic.yaml")
    update_schematic = file("${path.module}/../modules/talos/image/schematic.yaml")
  }

  cluster = {
    name               = "staging.talos.addeo.net"
    endpoint           = "10.1.15.92"
    gateway            = "10.1.15.1"
    proxmox_cluster    = "armada"
    kubernetes_version = "1.32.4"
  }

  nodes = {
    ctrl-01 = {
      host_node     = "crimson"
      machine_type  = "controlplane"
      ip            = "10.1.15.92"
      mac_address   = "0A:DD:E0:11:02:00"
      vm_id         = 200
      cpu           = 4
      ram_dedicated = 8192
    }
    work-01 = {
      host_node     = "crimson"
      machine_type  = "worker"
      ip            = "10.1.15.93"
      mac_address   = "0A:DD:E0:11:02:01"
      vm_id         = 201
      cpu           = 4
      ram_dedicated = 8192
    }
  }
}

module "proxmox_pvc_volumes" {
  source = "../modules/proxmox-volumes"

  providers = {
    restapi = restapi.proxmox
  }

  proxmox = {
    cluster_name = nonsensitive(var.proxmox.cluster_name)
  }

  volumes = local.pvc_volumes
}

module "rancher_oidc" {
  source = "../modules/rancher-genericoidc"

  providers = {
    restapi = restapi.rancher
  }

  oidc_provider = var.rancher_oidc_provider
}
