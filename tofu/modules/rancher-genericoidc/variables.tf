variable "oidc_provider" {
  type = object({
    clientId            = string
    clientSecret        = string
    issuer              = string
    authEndpoint        = string
    tokenEndpoint       = string
    userInfoEndpoint    = string
    jwksUrl             = string
    rancherUrl          = string
    scope               = optional(string, "openid profile email")
    groupSearchEnabled  = optional(bool, false)
    allowedPrincipalIds = list(string)
    accessMode          = string
  })
}
