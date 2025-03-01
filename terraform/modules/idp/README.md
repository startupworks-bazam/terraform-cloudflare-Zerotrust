# Cloudflare Identity Provider Module

This module configures Azure AD as an identity provider for Cloudflare Access.

## Usage

```hcl
module "idp" {
  source = "../../modules/idp"

  account_id          = var.account_id
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
  azure_directory_id  = var.azure_directory_id
}