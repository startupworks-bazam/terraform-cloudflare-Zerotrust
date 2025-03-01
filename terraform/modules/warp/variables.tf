variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "warp_name" {
  description = "Name for the WARP configuration"
  type        = string
  default     = "Default WARP Configuration"
}