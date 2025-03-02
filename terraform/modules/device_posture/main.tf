terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_zero_trust_device_posture_rule" "os_version" {
  account_id  = var.account_id
  name        = "OS Version Check"
  description = "Ensure devices are running up-to-date OS versions"
  type        = "os_version"
  
  match {
    platform = "windows"
  }
  
  input {
    version = ">=19045.5555"
  }
}

resource "cloudflare_zero_trust_gateway_policy" "device_posture" {
  account_id  = var.account_id
  name        = "Device Posture Check"
  description = "Enforce device posture requirements"
  precedence  = 1
  action      = "isolate"
  filters     = ["http", "https"]
  device_posture = jsonencode({
    integration_ids = [cloudflare_zero_trust_device_posture_rule.os_version.id]
  })
}