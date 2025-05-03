variable "cluster_name" {
  type    = string
  default = "talos-test"
}

variable "default_gateway" {
  type    = string
  default = "10.1.15.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "10.1.15.92"
}

variable "talos_worker_01_ip_addr" {
  type    = string
  default = "10.1.15.93"
}
