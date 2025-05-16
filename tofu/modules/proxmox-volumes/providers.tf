terraform {
  required_version = ">= 1.0"

  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.19.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.3"
    }
  }
}
