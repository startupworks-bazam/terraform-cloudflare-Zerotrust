variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "warp_name" {
  description = "Name for the WARP configuration"
  type        = string
  default     = "Default WARP Configuration"
}

variable "azure_ad_provider_id" {
  description = "ID of the Azure AD identity provider created in Cloudflare"
  type        = string
  default     = ""  # Making it optional with default empty string
}