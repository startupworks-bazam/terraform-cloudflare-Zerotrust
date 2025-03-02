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
  traffic     = "any(dns.name[*] in {})"  # Corrected expression
}

resource "cloudflare_zero_trust_gateway_policy" "block_malware" {
  account_id  = var.account_id
  name        = "Block Malware"
  description = "Block known malware domains"
  precedence  = 2
  action      = "block"
  filters     = ["dns"]
  traffic     = "any(dns.content_category[*] in {80})"  # Corrected traffic expression
}

# Block Security Threats
resource "cloudflare_zero_trust_gateway_policy" "block_security_threats" {
  account_id  = var.account_id
  name        = "Block Security Threats"
  description = "Block all known security threats based on Cloudflare's threat intelligence"
  precedence  = 1
  action      = "block"
  filters     = ["dns"]
  
  # Using proper security category syntax
  traffic = "any(dns.security_category[*] in {80})"  # Security Threats category
}

resource "cloudflare_zero_trust_gateway_policy" "block_streaming" {
  account_id  = var.account_id
  name        = "Block Unauthorized Streaming"
  description = "Block unauthorized streaming platforms"
  precedence  = 2
  action      = "block"
  filters     = ["http"]
  
  # Use http.request.uri categories instead of application field
  traffic     = "any(http.request.uri.content_category[*] in {96})"  # 96 is streaming media category
}

resource "cloudflare_zero_trust_gateway_policy" "cipa_filter" {
  account_id  = var.account_id
  name        = "CIPA Content Filtering"
  description = "Block all websites that fall under CIPA filter categories"
  precedence  = 3
  action      = "block"
  filters     = ["dns", "http"]
  
  # Use array syntax for content categories
  traffic     = "any(http.request.uri.content_category[*] in {1 4 5 6 7})"
}

resource "cloudflare_zero_trust_gateway_policy" "warp_enrollment" {
  account_id  = var.account_id
  name        = "WARP Enrollment for Security Teams"
  description = "Allow WARP enrollment for red and blue team members"
  precedence  = 10
  action      = "allow"
  filters     = ["http"]
  
  traffic     = "http.request.host eq 'reddome.cloudflareaccess.com'"
  
  identity = jsonencode({
    groups = [cloudflare_zero_trust_access_group.security_teams.id]
  })
}