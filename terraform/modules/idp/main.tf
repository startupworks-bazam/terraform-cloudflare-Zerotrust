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

# Add to idp/main.tf or create a new groups module
resource "cloudflare_zero_trust_access_group" "warp_users" {
  account_id = var.account_id
  name       = "WARP Users"
  
  include {
    gsuite {
      email = ["*@reddome.org"]
      identity_provider_id = cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id
    }
    azure {
      id = [cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id]
      name = ["Cloudflare_Warp_Users"]
    }
  }
}

resource "cloudflare_zero_trust_access_group" "warp_us_users" {
  account_id = var.account_id
  name       = "WARP US Users"
  
  include {
    azure {
      id = [cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id]
      name = ["Cloudflare_Warp_US_Users"]
    }
  }
}

resource "cloudflare_zero_trust_access_group" "infosec" {
  account_id = var.account_id
  name       = "InfoSec Team"
  
  include {
    azure {
      id = [cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id]
      name = ["InfoSec"]
    }
  }
}