resource "restapi_object" "genericoidc" {
  path = "/genericOIDCConfigs/genericoidc"

  create_method = "PUT"

  data = jsonencode({
    type                = "genericOIDCConfig"
    name                = "genericoidc"
    clientId            = var.oidc_provider.clientId
    clientSecret        = var.oidc_provider.clientSecret
    issuer              = var.oidc_provider.issuer
    authEndpoint        = var.oidc_provider.authEndpoint
    tokenEndpoint       = var.oidc_provider.tokenEndpoint
    userInfoEndpoint    = var.oidc_provider.userInfoEndpoint
    jwksUrl             = var.oidc_provider.jwksUrl
    rancherUrl          = var.oidc_provider.rancherUrl
    enabled             = true
    scope               = var.oidc_provider.scope
    groupSearchEnabled  = true
    allowedPrincipalIds = var.oidc_provider.allowedPrincipalIds
    accessMode          = var.oidc_provider.accessMode

  })
}
