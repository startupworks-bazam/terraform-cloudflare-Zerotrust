terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# 1. Define the Intune integration first
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

# 2. Define all the device posture rules
# OS Version Check
resource "cloudflare_zero_trust_device_posture_rule" "os_version_windows" {
  account_id = var.account_id
  name       = "Windows OS Version Check"
  type       = "os_version"
  description = "Ensure Windows devices are running supported OS version"

  input {
    minimum_version = "10.0.0"
    operator        = ">"
  }

  match {
    platform = "windows"
  }
}

# Disk Encryption Check
resource "cloudflare_zero_trust_device_posture_rule" "disk_encryption" {
  account_id = var.account_id
  name       = "Disk Encryption Check"
  type       = "disk_encryption"
  description = "Ensure device disk is encrypted"

  match {
    platform = "windows"
  }
}

# Antivirus Check
resource "cloudflare_zero_trust_device_posture_rule" "antivirus" {
  account_id = var.account_id
  name       = "Antivirus Running Check"
  type       = "application"
  description = "Ensure antivirus is running and up to date"

  input {
    running  = true
    id       = "antivirus"
  }

  match {
    platform = "windows"
  }
}

# Firewall Check
resource "cloudflare_zero_trust_device_posture_rule" "firewall" {
  account_id = var.account_id
  name       = "Firewall Running Check"
  type       = "application"
  description = "Ensure firewall is enabled"

  input {
    running  = true
    id       = "firewall"
  }

  match {
    platform = "windows"
  }
}

# Conditional Intune Compliance Rule (commented out by default)
# resource "cloudflare_zero_trust_device_posture_rule" "intune_compliance" {
#   account_id = var.account_id
#   name       = "Intune Compliance Check"
#   type       = "intune"
#   description = "Verify device compliance via Intune"
# 
#   input {
#     id                  = cloudflare_zero_trust_device_posture_integration.intune_integration.id
#     compliance_status   = "compliant"
#   }
# 
#   match {
#     platform = "windows"
#   }
# }