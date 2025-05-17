variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "rancher_api_token" {
  type      = string
  sensitive = true
}

variable "rancher_oidc_provider_client_id" {
  type      = string
  sensitive = true
}

variable "rancher_oidc_provider_client_secret" {
  type      = string
  sensitive = true
}

variable "rancher_oidc_provider_allowed_principal_ids" {
  type      = list(string)
  sensitive = true
}
