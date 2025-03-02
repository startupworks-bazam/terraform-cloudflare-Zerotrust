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
    claims         = ["email", "profile", "groups"]
  }
}

# Basic access groups without Azure integration for now
resource "cloudflare_zero_trust_access_group" "blue_team" {
  account_id = var.account_id
  name       = "Blue Team"
  
  include {
    email = ["user@reddome.org"]
  }
}

resource "cloudflare_zero_trust_access_group" "red_team" {
  account_id = var.account_id
  name       = "Red Team"
  
  include {
    email = ["user@reddome.org"]
  }
}

# Add this to terraform/modules/idp/main.tf
resource "cloudflare_zero_trust_access_group" "security_teams" {
  account_id = var.account_id
  name = "Security Teams"
  
  include {
    idp {
      id = cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id
      name = ["reddome_red_team", "reddome_blue_team"]
    }
  }
}