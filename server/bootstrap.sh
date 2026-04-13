#!/bin/bash
set -e

APP_DIR="/opt/citadel"
cd "$APP_DIR"

# Check origin certs exist
if [ ! -f "proxy/certs/origin.pem" ] || [ ! -f "proxy/certs/origin-key.pem" ]; then
  echo "ERROR: Origin certificates not found at proxy/certs/"
  echo "Generate them in Cloudflare: SSL/TLS → Origin Server → Create Certificate"
  echo "Then save origin.pem and origin-key.pem to proxy/certs/ on this server"
  exit 1
fi

echo "=== Origin certs found ==="
echo "=== Starting all services ==="
docker compose up -d

cat << BANNER

     _____ _ _            _      _
    / ____(_) |          | |    | |
   | |     _| |_ __ _  __| | ___| |
   | |    | | __/ _' |/ _' |/ _ \ |
   | |____| | || (_| | (_| |  __/ |
    \_____|_|\__\__,_|\__,_|\___|_|

  Vault:   https://citadel-vault.hbprojects.app
  Monitor: https://citadel-monitor.hbprojects.app
  Logs:    https://citadel-logs.hbprojects.app

  NEXT: Visit Vault URL to initialize.
  Save your unseal key and root token somewhere safe.

BANNER
