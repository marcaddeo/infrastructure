resource "restapi_object" "this" {
  for_each = var.volumes

  path = "/api2/json/nodes/${each.value.node}/storage/${each.value.storage}/content/"

  id_attribute = "data"

  force_new = [each.value.size]

  data = jsonencode({
    vmid     = each.value.vmid
    filename = "vm-${each.value.vmid}-${each.key}"
    size     = each.value.size
    format   = each.value.format
  })

  lifecycle {
    prevent_destroy = true
  }
}
