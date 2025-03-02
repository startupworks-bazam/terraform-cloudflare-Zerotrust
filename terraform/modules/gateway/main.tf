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
  
  # Fix networks format
  networks {
    network = var.networks[0]  # Use first network in list
  }
  
  # If you need multiple networks, add them individually
  dynamic "networks" {
    for_each = length(var.networks) > 1 ? slice(var.networks, 1, length(var.networks)) : []
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
  traffic     = "true"  # Simplest expression that will match everything
}