# ──────────────────────────────────────────────
# Cloudflare Zero Trust Access
#
# Puts a login wall (email OTP) in front of all
# citadel services. Only admin_email can access.
# ──────────────────────────────────────────────

# ── Access application for Vault ──
resource "cloudflare_zero_trust_access_application" "vault" {
  account_id          = var.cloudflare_account_id
  name             = "Citadel Vault"
  domain           = "citadel-vault.hbprojects.app"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "vault_policy" {
  account_id        = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.vault.id
  name           = "Allow admin"
  decision       = "allow"
  precedence     = 1

  include {
    email = [var.admin_email]
  }
}

# ── Access application for Uptime Kuma ──
resource "cloudflare_zero_trust_access_application" "monitor" {
  account_id          = var.cloudflare_account_id
  name             = "Citadel Monitor"
  domain           = "citadel-monitor.hbprojects.app"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "monitor_policy" {
  account_id        = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.monitor.id
  name           = "Allow admin"
  decision       = "allow"
  precedence     = 1

  include {
    email = [var.admin_email]
  }
}

# ── Access application for Dozzle ──
resource "cloudflare_zero_trust_access_application" "logs" {
  account_id          = var.cloudflare_account_id
  name             = "Citadel Logs"
  domain           = "citadel-logs.hbprojects.app"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "logs_policy" {
  account_id        = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.logs.id
  name           = "Allow admin"
  decision       = "allow"
  precedence     = 1

  include {
    email = [var.admin_email]
  }
}
