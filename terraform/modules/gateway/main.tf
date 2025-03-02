terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Changed from cloudflare_teams_location to cloudflare_zero_trust_dns_location
resource "cloudflare_zero_trust_dns_location" "gateway" {
  account_id = var.account_id
  name       = "Default Gateway"
  networks   = ["192.168.1.0/24"]
}

resource "cloudflare_zero_trust_gateway_policy" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  description = "Gateway default policy"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  traffic     = "any()"  # Corrected traffic expression
}