# In environments/prod/main.tf
terraform {
  cloud {
    organization = "reddome_academy"
    workspaces {
      name = "terraform-cloudflare-Zerotrust"
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

# Global Zero Trust configuration
resource "cloudflare_zero_trust_gateway_settings" "zero_trust" {
  account_id = var.account_id
}

module "warp" {
  source = "../../modules/warp"
  account_id = var.account_id
  warp_name  = "Prod WARP Configuration"
  depends_on = [cloudflare_zero_trust_gateway_settings.zero_trust]
}

module "device_posture" {
  source = "../../modules/device_posture"
  account_id = var.account_id
  depends_on = [cloudflare_zero_trust_gateway_settings.zero_trust]
}

module "gateway" {
  source = "../../modules/gateway"
  account_id    = var.account_id
  location_name = "Prod Gateway"
  networks      = ["192.168.1.0/24"]
  depends_on    = [cloudflare_zero_trust_gateway_settings.zero_trust]
}

module "access" {
  source = "../../modules/access"
  account_id     = var.account_id
  app_name       = "Example App"
  app_domain     = "reddome.cloudflareaccess.com"  # Replace with a domain you own in Cloudflare
  allowed_emails = ["user@reddome.org"]
  depends_on     = [cloudflare_zero_trust_gateway_settings.zero_trust]
}

module "idp" {
  source = "../../modules/idp"
  account_id          = var.account_id
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
  azure_directory_id  = var.azure_directory_id
  depends_on = [cloudflare_zero_trust_gateway_settings.zero_trust]
}