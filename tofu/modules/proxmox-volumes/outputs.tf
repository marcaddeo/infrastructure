output "proxmox_volumes" {
  value = [for name, v in var.volumes : "${var.proxmox.cluster_name}/${v.node}/${v.storage}/vm-${v.vmid}-${name}"]
}
