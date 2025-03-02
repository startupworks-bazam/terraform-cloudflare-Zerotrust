# terraform/modules/idp/main.tf
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4.40.0"
    }
  }
}

resource "cloudflare_zero_trust_access_identity_provider" "microsoft_entra_id" {
  account_id = var.account_id
  name       = "Microsoft Entra ID"
  type       = "azureAD"
  config {
    client_id      = var.azure_client_id
    client_secret  = var.azure_client_secret
    directory_id   = var.azure_directory_id
    support_groups = true
    # Add custom claims mapping if UPN != email
    claims         = ["email", "profile", "groups"]
  }
}

# Updated access groups for IDP module - simplifying to avoid syntax errors
resource "cloudflare_zero_trust_access_group" "blue_team" {
  account_id = var.account_id
  name       = "Blue Team"
  
  include {
    email = ["user@reddome.org"]  # Adding a default email as placeholder
  }
}

resource "cloudflare_zero_trust_access_group" "red_team" {
  account_id = var.account_id
  name       = "Red Team"
  
  include {
    email = ["user@reddome.org"]  # Adding a default email as placeholder
  }
}