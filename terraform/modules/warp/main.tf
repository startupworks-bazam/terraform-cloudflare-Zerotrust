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
  # Per documentation:
  traffic     = "all(dns.type in {A, AAAA, CNAME, TXT})"
}

resource "cloudflare_zero_trust_gateway_policy" "block_malware" {
  account_id  = var.account_id
  name        = "Block Malware"
  description = "Block known malware domains"
  precedence  = 2
  action      = "block"
  filters     = ["dns"]
  # Per documentation:
  traffic     = "all(dns.content_category in {80})"
  rule_settings {
    block_page_enabled = true
    block_page_reason  = "Your administrator has blocked your request."
  }
}

resource "cloudflare_zero_trust_gateway_policy" "unwanted" {
  account_id  = var.account_id
  name        = "Block Unwanted Sites (CIPA)"
  description = "block all websites thats not required for the business"
  precedence  = 10
  action      = "block"
  filters     = ["http"]
  traffic     = "any(http.request.uri.content_category[*] in {182})"
  rule_settings {
    block_page_enabled = true
    block_page_reason  = "Your administrator has blocked your request."
  }
}