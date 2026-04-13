# ──────────────────────────────────────────────
# Cloudflare Zero Trust Access
#
# Puts a login wall (email OTP) in front of all
# citadel services. Only admin_email can access.
# ──────────────────────────────────────────────

# ── Access application for Vault ──
resource "cloudflare_zero_trust_access_application" "vault" {
  zone_id          = var.cloudflare_zone_id
  name             = "Citadel Vault"
  domain           = "vault.citadel.hbprojects.app"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "vault_policy" {
  zone_id        = var.cloudflare_zone_id
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
  zone_id          = var.cloudflare_zone_id
  name             = "Citadel Monitor"
  domain           = "monitor.citadel.hbprojects.app"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "monitor_policy" {
  zone_id        = var.cloudflare_zone_id
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
  zone_id          = var.cloudflare_zone_id
  name             = "Citadel Logs"
  domain           = "logs.citadel.hbprojects.app"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "logs_policy" {
  zone_id        = var.cloudflare_zone_id
  application_id = cloudflare_zero_trust_access_application.logs.id
  name           = "Allow admin"
  decision       = "allow"
  precedence     = 1

  include {
    email = [var.admin_email]
  }
}
