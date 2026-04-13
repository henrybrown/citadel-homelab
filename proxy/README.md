# Proxy — Nginx + SSL

Reverse proxy routing subdomains to services. Handles SSL termination via Let's Encrypt.

## Routing

| Subdomain | Service | Port |
|-----------|---------|------|
| vault.citadel.hbprojects.app | Vault | 8200 |
| monitor.citadel.hbprojects.app | Uptime Kuma | 3001 |
| logs.citadel.hbprojects.app | Dozzle | 8080 |
| citadel.hbprojects.app | Health check JSON | — |

## Adding a new service

1. Add its docker-compose.yml in a new slice directory
2. Include it in the root docker-compose.yml
3. Add a server block in nginx.conf
4. Restart: `docker compose up -d`

No DNS changes needed — the wildcard `*.citadel.hbprojects.app` catches everything.
