variable "proxmox" {
  type = object({
    name         = string
    cluster_name = string
    endpoint     = string
    insecure     = bool
    api_token    = string
    username     = string
    private_key  = string
  })
  sensitive = true
}
