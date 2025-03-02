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
  
  # The correct syntax based on Cloudflare provider documentation
  client_default = true
  
  # For each network in the var.networks list
  dynamic "ip_rules" {
    for_each = var.networks
    content {
      ip = ip_rules.value
    }
  }
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