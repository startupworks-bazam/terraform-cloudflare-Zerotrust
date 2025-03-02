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
  
  # Proper syntax for defining networks
  dynamic "networks" {
    for_each = var.networks
    content {
      network = networks.value
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
  
  # Correct syntax based on Cloudflare provider
  traffic = "(http.request.uri)"  # This is a basic expression that matches all HTTP traffic
  
  # If you need to filter DNS, try:
  # traffic = "(dns)"
}