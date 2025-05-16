variable "volumes" {
  type = map(
    object({
      node    = string
      size    = string
      storage = optional(string, "vmpool")
      vmid    = optional(number, 9999)
      format  = optional(string, "raw")
    })
  )
}

variable "proxmox" {
  type = object({
    cluster_name = string
  })
}
