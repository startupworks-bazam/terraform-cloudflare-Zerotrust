# In modules/gateway/main.tf
resource "cloudflare_teams_location" "gateway" {
  account_id = var.account_id
  name       = var.location_name
  networks   = var.networks
}

resource "cloudflare_teams_rule" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  
  traffic {
    protocols = ["any"]
  }
}