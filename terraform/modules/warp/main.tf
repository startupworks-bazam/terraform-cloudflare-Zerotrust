terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_zero_trust_gateway_policy" "allow_all" {
  account_id  = var.account_id
  name        = "Allow All Traffic"
  description = "Allow all traffic through WARP"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  traffic     = "true"  # Simplest expression that will match everything
}

resource "cloudflare_zero_trust_gateway_policy" "block_malware" {
  account_id  = var.account_id
  name        = "Block Malware"
  description = "Block known malware domains"
  precedence  = 2
  action      = "block"
  filters     = ["dns"]
  traffic     = "cf.threat_category == 'malware'"  # Use proper Cloudflare filtering syntax
}