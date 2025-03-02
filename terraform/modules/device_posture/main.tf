terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
# Microsoft Intune Integration with your Entra app
resource "cloudflare_zero_trust_device_posture_rule" "intune_integration" {
  account_id  = var.account_id
  name        = "Microsoft Intune Compliance"
  description = "Verify device compliance with Intune policies via ZTNAPostureChecks app"
  type        = "intune"
  
  match {
    platform = "all"
  }
  
  input {
    client_id     = var.intune_client_id
    client_secret = var.intune_client_secret
    tenant_id     = var.azure_tenant_id
  }
}

# OS Version Check
resource "cloudflare_zero_trust_device_posture_rule" "os_version_windows" {
  account_id  = var.account_id
  name        = "Windows OS Version Check"
  description = "Ensure Windows devices are running supported OS version"
  type        = "os_version"
  
  match {
    platform = "windows"
  }
  
  input {
    version = "10.0"  # Windows 10
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
  device_posture = jsonencode({
    integration_ids = [cloudflare_zero_trust_device_posture_rule.os_version_windows.id]
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