terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Comment out the DNS location
# resource "cloudflare_zero_trust_dns_location" "gateway" {
#   account_id = var.account_id
#   name       = var.location_name
#   endpoints {
#     ipv4 {
#       enabled = true
#     }
#     ipv6 {
#       enabled = false
#     }
#     doh {
#       enabled = false
#     }
#     dot {
#       enabled = false
#     }
#   }
# }

resource "cloudflare_zero_trust_gateway_settings" "zero_trust" {
  account_id = var.account_id
}

resource "cloudflare_zero_trust_gateway_policy" "gateway_policy" {
  account_id  = var.account_id
  name        = "Default Gateway Policy"
  description = "Gateway default policy"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  traffic     = "any()"
  depends_on  = [cloudflare_zero_trust_gateway_settings.zero_trust]
  identity {
    groups = [var.security_teams_id]
  }
}

module "gateway" {
  source            = "../../modules/gateway"
  account_id        = var.account_id
  location_name     = "Prod Gateway"
  networks          = ["192.168.1.0/24"]
  security_teams_id = module.idp.security_teams_id
  depends_on        = [cloudflare_zero_trust_gateway_settings.zero_trust]
}

resource "cloudflare_zero_trust_device_posture_rule" "disk_encryption" {
  name        = "Disk Encryption Check"
  account_id  = var.account_id
  platform    = "windows"
  match {
    type        = "disk_encryption"
  }
}

resource "cloudflare_zero_trust_device_posture_rule" "os_version_windows" {
  name        = "Windows OS Version Check"
  account_id  = var.account_id
  platform    = "windows"
  match {
    type        = "os_version"
    version     = "10.15.7"
  }
}

resource "cloudflare_zero_trust_device_posture_integration" "intune_integration" {
  name          = "Microsoft Intune Integration"
  account_id    = var.account_id
  type          = "intune"
  config {
    interval     = "10m"
    client_id    = var.intune_client_id
    client_secret = var.intune_client_secret
    customer_id  = var.azure_tenant_id
  }
}

module "access" {
  source = "../../modules/access"
  account_id     = var.account_id
  app_name       = "Example App"
  app_domain     = "app.reddome.org"  # Replace with a domain you own in Cloudflare
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

module "warp" {
  source = "../../modules/warp"
  account_id = var.account_id
  warp_name  = "Prod WARP Configuration"
  azure_ad_provider_id = module.idp.entra_idp_id
  security_teams_id = module.idp.security_teams_id
  depends_on = [cloudflare_zero_trust_gateway_settings.zero_trust, module.idp]
}