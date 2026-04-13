#!/bin/bash
set -e

DOMAIN="citadel.hbprojects.app"
EMAIL="henry.e.brown@icloud.com"
APP_DIR="/opt/citadel"

cd "$APP_DIR"

echo "=== Generating SSL certificates ==="

mkdir -p proxy/certbot/conf

docker run --rm -p 80:80 \
  -v "$APP_DIR/proxy/certbot/conf:/etc/letsencrypt" \
  certbot/certbot certonly \
  --standalone \
  --non-interactive \
  -d "$DOMAIN" \
  -d "vault.$DOMAIN" \
  -d "monitor.$DOMAIN" \
  -d "logs.$DOMAIN" \
  --agree-tos \
  -m "$EMAIL"

echo "=== Starting all services ==="
docker compose up -d

cat << BANNER

     _____ _ _            _      _
    / ____(_) |          | |    | |
   | |     _| |_ __ _  __| | ___| |
   | |    | | __/ _' |/ _' |/ _ \ |
   | |____| | || (_| | (_| |  __/ |
    \_____|_|\__\__,_|\__,_|\___|_|

  Vault:   https://vault.$DOMAIN
  Monitor: https://monitor.$DOMAIN
  Logs:    https://logs.$DOMAIN

  NEXT: Visit Vault URL to initialize.
  Save your unseal key and root token somewhere safe.

BANNER
