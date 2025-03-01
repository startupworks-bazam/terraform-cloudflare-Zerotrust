# Terraform Cloudflare Zero Trust

This project manages Cloudflare Zero Trust configuration using Terraform including:
- WARP Configuration
- Device Posture Checks
- Gateway Settings
- Access Applications
- Azure AD Integration

## Prerequisites
- Terraform Cloud account
- Cloudflare account with Zero Trust enabled
- Azure AD tenant for identity provider

## Usage
1. Configure Terraform Cloud workspace
2. Set required variables in Terraform Cloud
3. Run Terraform apply

## Modules
- `warp`: Configures WARP client settings
- `device_posture`: Manages device posture rules
- `gateway`: Configures Cloudflare Gateway
- `access`: Manages access applications
- `idp`: Configures Azure AD integration