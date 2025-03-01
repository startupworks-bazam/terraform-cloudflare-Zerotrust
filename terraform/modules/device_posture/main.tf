resource "cloudflare_teams_rules" "device_posture" {
  account_id  = var.account_id
  name        = "Device Posture Check"
  description = "Enforce device posture requirements"
  precedence  = 1
  action      = "isolate"
  filters     = ["device_posture"]
  traffic     = "any()"
}