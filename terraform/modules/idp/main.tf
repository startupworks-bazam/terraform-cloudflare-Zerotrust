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

# Replace the current security_teams group with this
resource "cloudflare_zero_trust_access_group" "security_teams" {
  account_id = var.account_id
  name = "Security Teams"
  
  include {
    azure {
      id = ["a3008467-e39c-43f6-a7ad-4769bcefe01e", "5a071d2a-8597-4096-a6b3-1d702cfab3c4"]
      identity_provider_id = cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id
    }
  }
}