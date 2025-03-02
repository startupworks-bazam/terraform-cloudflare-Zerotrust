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
  
  # Explicitly configure all endpoints to prevent crashes
  endpoints {
    ipv4 {
      enabled = true
    }
    ipv6 {
      enabled = false
    }
    doh {
      enabled = false
    }
    dot {
      enabled = false
    }
  }
  
  # Only add networks if specified
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
  description = "Gateway default policy"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  traffic = "dns.query_name matches '*'"
}