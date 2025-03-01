terraform {
  cloud {
    organization = "your-org-name"
    workspaces {
      name = "cloudflare-zerotrust-dev"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.api_token
}

module "warp" {
  source = "../../modules/warp"

  account_id = var.account_id
  api_token  = var.api_token
  warp_name  = "Dev WARP Configuration"
}