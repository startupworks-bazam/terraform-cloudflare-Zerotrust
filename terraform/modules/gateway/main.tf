resource "cloudflare_teams_location" "gateway" {
  account_id = var.account_id
  name       = var.location_name
  networks   = var.networks
}

resource "cloudflare_teams_gateway_policy" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  traffic     = "any()"
}