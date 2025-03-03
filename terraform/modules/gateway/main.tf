terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_zero_trust_dns_location" "gateway" {
  account_id = var.account_id
  name       = var.location_name
  
  networks {
    network = var.networks[0]
  }
}

resource "cloudflare_zero_trust_gateway_policy" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  description = "Gateway default policy"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  traffic     = "any()"
  
  identity {
    groups = [var.security_teams_id]
  }
}