variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "warp_name" {
  description = "Name for the WARP configuration"
  type        = string
  default     = "Default WARP Configuration"
}