# In modules/device_posture/main.tf
resource "cloudflare_teams_device_posture_rule" "os_version" {
  account_id  = var.account_id
  name        = "OS Version Check"
  description = "Ensure devices are running up-to-date OS versions"
  type        = "os_version"
  
  match {
    platform = "windows"
  }
  
  input {
    version = ">=10.0.0"
  }
}

resource "cloudflare_teams_rule" "device_posture" {
  account_id  = var.account_id
  name        = "Device Posture Check"
  description = "Enforce device posture requirements"
  precedence  = 1
  action      = "isolate"
  filters     = ["http", "https"]
  
  device_posture {
    integration_ids = [cloudflare_teams_device_posture_rule.os_version.id]
  }
}