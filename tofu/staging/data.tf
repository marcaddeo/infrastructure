data "external" "pvc_volumes" {
  program = ["just", "pvc-volumes"]
}
