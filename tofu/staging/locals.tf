locals {
  pvc_volumes = try(jsondecode(base64decode(data.external.pvc_volumes.result.base64)), {})
}
