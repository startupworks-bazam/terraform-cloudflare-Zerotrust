terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# OS Version Check (keep this one as-is)
resource "cloudflare_zero_trust_device_posture_rule" "os_version_windows" {
  account_id  = var.account_id
  name        = "Windows OS Version Check"
  description = "Ensure Windows devices are running supported OS version"
  type        = "os_version"
  
  match {
    platform = "windows"
  }
  
  input {
    version = "10.15.7"  # Windows 10
  }
}

# Fix the reference to os_version_windows
resource "cloudflare_zero_trust_gateway_policy" "device_posture" {
  account_id  = var.account_id
  name        = "Device Posture Check"
  description = "Enforce device posture requirements"
  precedence  = 1
  action      = "isolate"
  filters     = ["http", "https"]
  
  # Use a proper filter expression based on your working example
  traffic     = "http.request.uri eq true"
  
  # Use device_posture instead of identity
  device_posture = jsonencode({
    integration_ids = [
      cloudflare_zero_trust_device_posture_rule.os_version_windows.id,
      cloudflare_zero_trust_device_posture_rule.disk_encryption.id,
      cloudflare_zero_trust_device_posture_rule.intune_integration.id
    ]
  })
}

# Disk Encryption Check
resource "cloudflare_zero_trust_device_posture_rule" "disk_encryption" {
  account_id  = var.account_id
  name        = "Disk Encryption Check"
  description = "Verify devices have disk encryption enabled"
  type        = "disk_encryption"
  
  match {
    platform = "windows"
  }
}

# Add this Intune integration resource
# For device_posture/main.tf
resource "cloudflare_zero_trust_device_posture_integration" "intune_integration" {
  account_id = var.account_id
  name       = "Microsoft Intune Integration"
  type       = "intune"
  interval   = "10m"
  
  config {
    client_id     = var.intune_client_id
    client_secret = var.intune_client_secret
    customer_id   = var.azure_tenant_id
  }
}

resource "cloudflare_zero_trust_device_posture_rule" "intune_integration" {
  account_id  = var.account_id
  name        = "Microsoft Intune Compliance"
  description = "Verify device compliance with Intune policies"
  type        = "intune"
  
  match {
    platform = "all"
  }
  
  # For Intune integration, we need to use input block with correct attribute
  input {
    # This is the correct format - the ID goes inside the input block
    id = cloudflare_zero_trust_device_posture_integration.intune_integration.id
  }
}