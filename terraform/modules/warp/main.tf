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

# Block Streaming (updated group names)
resource "cloudflare_zero_trust_gateway_policy" "block_streaming" {
  account_id  = var.account_id
  name        = "Block Unauthorized Streaming"
  description = "Block unauthorized streaming platforms"
  precedence  = 2
  action      = "block"
  filters     = ["http"]
  
  # Block streaming applications
  traffic = "any(application[*] in {'Netflix', 'Amazon Prime Video'})"
  
  # Updated group names
  identity {
    id = [var.azure_ad_provider_id]
    email_list = []
    group_list = ["reddome_blue_team", "reddome_red_team"]
  }
}

# CIPA Content Filtering (updated group names)
resource "cloudflare_zero_trust_gateway_policy" "cipa_filter" {
  account_id  = var.account_id
  name        = "CIPA Content Filtering"
  description = "Block all websites that fall under CIPA filter categories"
  precedence  = 3
  action      = "block"
  filters     = ["dns", "http"]
  
  # Target CIPA filter categories
  traffic = "any(dns.content_category[*] in {'Adult Content', 'Gambling', 'Weapons', 'Drugs', 'Pornography'})"
  
  # Updated group names
  identity {
    id = [var.azure_ad_provider_id]
    group_list = ["reddome_blue_team", "reddome_red_team"]
  }
}

# Blue Team WARP settings
resource "cloudflare_zero_trust_device_settings" "warp_settings_blue" {
  account_id = var.account_id
  
  # Enable captive portal detection
  captive_portal {
    enable  = true
    timeout = 300
  }
  
  # Disable client tampering
  allow_mode_switch = false
  allow_updates     = true
  switch_locked     = true
  
  # Enable admin override with OTP
  auto_connect = 3600  # Auto-connect timeout
  
  # Install Cloudflare CA certificate
  root_certificate {
    enabled = true
  }
  
  # Apply to Blue Team
  identity {
    id = [var.azure_ad_provider_id]
    group_list = ["reddome_blue_team"]
  }
}

# Red Team settings with TLS inspection enabled
resource "cloudflare_zero_trust_device_settings" "warp_settings_red" {
  account_id = var.account_id
  
  # Base settings similar to default
  captive_portal {
    enable  = true
    timeout = 300
  }
  
  switch_locked = true
  allow_updates = true
  
  # Enable TLS inspection for Red Team (formerly US users)
  tls_decrypt {
    enabled = true
  }
  
  # Apply to Red Team
  identity {
    id = [var.azure_ad_provider_id]
    group_list = ["reddome_red_team"]
  }
}

# Enable TLS decryption for traffic inspection
resource "cloudflare_zero_trust_gateway_settings" "tls_settings" {
  account_id = var.account_id
  
  # Enable TLS decryption
  tls {
    enable = true
  }
  
  # Enable antivirus scanning
  antivirus {
    enabled_download_scan = true
    enabled_upload_scan   = true
    block_unscannable     = true
  }
}