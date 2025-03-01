# Cloudflare Zero Trust WARP Module

This module configures Cloudflare Zero Trust WARP settings including:
- Teams Account Setup
- Basic Allow All Traffic Rule
- Malware Blocking Rule

## Usage

```hcl
module "warp" {
  source = "../../modules/warp"

  account_id = var.account_id
  api_token  = var.api_token
  warp_name  = "My WARP Configuration"
}