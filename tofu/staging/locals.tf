locals {
  proxmox = {
    name         = "crimson"
    cluster_name = "armada"
    endpoint     = "https://crimson.addeo.net:8006/"
    insecure     = true
    api_token    = var.proxmox_api_token
    username     = "ansible"
    private_key  = file("${path.module}/../../ansible/host_keys/id_rsa.ansible@addeo.net")
  }

  pvc_volumes = try(jsondecode(base64decode(data.external.pvc_volumes.result.base64)), {})

  rancher = {
    endpoint  = "https://rancher.staging.addeo.net/v3"
    insecure  = true
    api_token = var.rancher_api_token
  }

  rancher_oidc_provider = {
    clientId            = var.rancher_oidc_provider_client_id
    clientSecret        = var.rancher_oidc_provider_client_secret
    issuer              = "https://id.staging.addeo.net"
    authEndpoint        = "https://id.staging.addeo.net/authorize"
    tokenEndpoint       = "https://id.staging.addeo.net/api/oidc/token"
    userInfoEndpoint    = "https://id.staging.addeo.net/api/oidc/userinfo"
    jwksUrl             = "https://id.staging.addeo.net/.well-known/jwks.json"
    rancherUrl          = "https://rancher.staging.addeo.net/verify-auth"
    scope               = "openid profile email"
    groupSearchEnabled  = true
    allowedPrincipalIds = var.rancher_oidc_provider_allowed_principal_ids
    accessMode          = "unrestricted"
  }
}
