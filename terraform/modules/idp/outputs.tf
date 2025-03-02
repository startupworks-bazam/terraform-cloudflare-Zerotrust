# terraform/modules/idp/outputs.tf
output "entra_idp_id" {
  value = cloudflare_zero_trust_access_identity_provider.microsoft_entra_id.id
}