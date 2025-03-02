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

# Updated access groups for IDP module using correct group syntax
resource "cloudflare_zero_trust_access_group" "blue_team" {
  account_id = var.account_id
  name       = "Blue Team"
  
  include {
    azure {
      id = [cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id]
      identity_provider_id = cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id
      # Using the ID instead of name for group reference
      groups = ["reddome_blue_team"]
    }
  }
}

resource "cloudflare_zero_trust_access_group" "red_team" {
  account_id = var.account_id
  name       = "Red Team"
  
  include {
    azure {
      id = [cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id]
      identity_provider_id = cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id
      # Using the ID instead of name for group reference
      groups = ["reddome_red_team"]
    }
  }
}