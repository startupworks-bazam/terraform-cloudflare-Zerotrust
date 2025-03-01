resource "cloudflare_teams_account" "warp" {
  account_id = var.account_id
  name       = var.warp_name
}

resource "cloudflare_teams_rule" "allow_all" {
  account_id  = var.account_id
  name        = "Allow All Traffic"
  description = "Allow all traffic through WARP"
  precedence  = 1
  action      = "allow"
  filters     = ["dns"]
  traffic     = "any()"
}

resource "cloudflare_teams_rules" "block_malware" {
  account_id  = var.account_id
  name        = "Block Malware"
  description = "Block known malware domains"
  precedence  = 2
  action      = "block"
  filters     = ["dns"]
  traffic     = "security.category in {malware}"
}