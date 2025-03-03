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

# Optional Intune Compliance Rule
resource "cloudflare_zero_trust_device_posture_rule" "intune_compliance" {
  account_id = var.account_id
  name       = "Intune Compliance Check"
  type       = "intune"
  description = "Verify device compliance via Intune"

  input {
    id                = cloudflare_zero_trust_device_posture_integration.intune_integration.id
    compliance_status = "compliant"
  }

  match {
    platform = "windows"
  }
}