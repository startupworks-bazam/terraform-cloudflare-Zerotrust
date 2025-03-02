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
  
  # Correct syntax for networks
  networks {
    network = "10.0.0.0/8"
  }
  
  networks {
    network = "192.168.1.0/24"
  }
  
  # Optionally set client_default
  client_default = false
}

resource "cloudflare_zero_trust_gateway_policy" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  description = "Default policy for gateway traffic"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  # Correct syntax for traffic filter
  traffic     = "dns.type in {\"A\" \"AAAA\"}"
}