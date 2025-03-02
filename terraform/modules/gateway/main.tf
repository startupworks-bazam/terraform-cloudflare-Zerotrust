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
  
  # Define the IP networks that this location covers
  networks {
    network = "192.168.1.0/24"  # Example: your internal network CIDR
  }
  
  # You can add multiple networks
  networks {
    network = "10.0.0.0/8"  # Example: another internal network
  }
  
  client_default = false  # Set to true if this should be the default location
}

resource "cloudflare_zero_trust_gateway_policy" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  description = "Default policy for gateway traffic"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  # Per documentation, use this format:
  traffic = "(dns.type in {A AAAA})"
}