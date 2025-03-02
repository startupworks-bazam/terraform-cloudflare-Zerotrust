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
# Block Malware and Security Threats
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

# Block Unauthorized Applications (Streaming Platforms)
resource "cloudflare_zero_trust_gateway_policy" "block_streaming" {
  account_id  = var.account_id
  name        = "Block Unauthorized Streaming"
  description = "Block unauthorized streaming platforms"
  precedence  = 2
  action      = "block"
  filters     = ["http"]
  
  # Block streaming applications
  traffic = "any(application[*] in {'Netflix', 'Amazon Prime Video'})"
  
  # Reference Azure AD group for UK Users
  identity {
    id = [var.azure_ad_provider_id]
    email_list = []
    group_list = ["Cloudflare_Warp_Users"]  # Using exact group name from Entra
  }
}

# CIPA Content Filtering
resource "cloudflare_zero_trust_gateway_policy" "cipa_filter" {
  account_id  = var.account_id
  name        = "CIPA Content Filtering"
  description = "Block all websites that fall under CIPA filter categories"
  precedence  = 3
  action      = "block"
  filters     = ["dns", "http"]
  
  # Target CIPA filter categories
  traffic = "any(dns.content_category[*] in {'Adult Content', 'Gambling', 'Weapons', 'Drugs', 'Pornography'})"
  
  # Apply to all users
  identity {
    id = [var.azure_ad_provider_id]
    group_list = ["Cloudflare_Warp_Users", "Cloudflare_Warp_US_Users"]
  }
}

# Block Unapproved File Sharing (Testing with InfoSec team)
resource "cloudflare_zero_trust_gateway_policy" "block_file_upload" {
  account_id  = var.account_id
  name        = "Block Unapproved File Sharing"
  description = "Block file uploads to unapproved platforms"
  precedence  = 4
  action      = "block"
  filters     = ["http"]
  
  # Detect and block file uploads to unauthorized services
  traffic = "http.request.method == 'POST' and any(http.request.file.name[*] exists) and any(application[*] in {'Dropbox', 'Cyberduck', 'WeTransfer'})"
  
  # Only apply to InfoSec group for testing
  identity {
    id = [var.azure_ad_provider_id]
    group_list = ["InfoSec"]  # Using the temp testing group from Entra
  }
}

# Default WARP client configurations
resource "cloudflare_zero_trust_device_settings" "warp_settings" {
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
  
  # Apply to UK users group
  identity {
    id = [var.azure_ad_provider_id]
    group_list = ["Cloudflare_Warp_Users"]
  }
}

# US-specific settings with TLS inspection enabled
resource "cloudflare_zero_trust_device_settings" "warp_settings_us" {
  account_id = var.account_id
  
  # Base settings similar to default
  captive_portal {
    enable  = true
    timeout = 300
  }
  
  switch_locked = true
  allow_updates = true
  
  # Enable TLS inspection for US users
  tls_decrypt {
    enabled = true
  }
  
  # Apply to US users group
  identity {
    id = [var.azure_ad_provider_id]
    group_list = ["Cloudflare_Warp_US_Users"]
  }
}

# Enable TLS decryption for traffic inspection
resource "cloudflare_zero_trust_gateway_settings" "tls_settings" {
  account_id = var.account_id
  
  # Enable TLS decryption
  tls {
    enable = true
  }
  
  # Enable antivirus scanning as shown in your document
  antivirus {
    enabled_download_scan = true
    enabled_upload_scan   = true
    block_unscannable     = true
  }
}