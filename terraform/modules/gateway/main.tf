terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_zero_trust_dns_location" "gateway" {
  account_id    = var.account_id
  name          = var.location_name
  client_default = false
  
  # Correct format for networks
  networks {
    network = "192.168.1.0/24"
  }
  
  # If you have multiple networks, add them like this
  # networks {
  #   network = "10.0.0.0/8"
  # }
}
resource "cloudflare_zero_trust_gateway_policy" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  description = "Default policy for gateway traffic"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  
  # Similar format to your working CIPA filter
  traffic     = "any(http.request.uri.content_category[*] in {1})"  # This is a placeholder, use appropriate category ID
  
  rule_settings {
    block_page_enabled = false
  }
}