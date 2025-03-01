resource "cloudflare_access_identity_provider" "azure_ad" {
  account_id = var.account_id
  name       = "Azure AD"
  type       = "azure"
  config {
    client_id     = var.azure_client_id
    client_secret = var.azure_client_secret
    directory_id  = var.azure_directory_id
  }
}