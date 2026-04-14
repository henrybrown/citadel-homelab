# Proxy

Nginx reverse proxy that routes all incoming traffic to the correct service based on subdomain. It handles SSL termination using Cloudflare origin certificates and serves static demo apps directly from disk.

## Access

- **Container:** `citadel-nginx`
- **Image:** `nginx:alpine`
- **Ports:** 80 (HTTP redirect), 443 (HTTPS)
- **Config:** `nginx.conf` (mounted as `/etc/nginx/conf.d/default.conf`)

## How it works

All subdomains under `hbprojects.app` point to the same server IP via Cloudflare DNS. Nginx uses the `server_name` directive to route each request to the right backend:

| Subdomain | Backend |
|-----------|---------|
| citadel-vault.hbprojects.app | Vault container (port 8200) |
| citadel-monitor.hbprojects.app | Uptime Kuma container (port 3001) |
| citadel-logs.hbprojects.app | Dozzle container (port 8080) |
| music-visualiser.hbprojects.app | Static files from `demos/music-visualiser/dist/` |
| music-visualizer.hbprojects.app | Same as above (US spelling alias) |
| citadel.hbprojects.app | Health check JSON response |

All HTTP traffic is redirected to HTTPS. Rate limiting is applied globally at 10 req/s with a burst of 20.

## SSL certificates

SSL uses Cloudflare origin certificates stored at `certs/origin.pem` and `certs/origin-key.pem`. These are:

- Generated in the Cloudflare dashboard (SSL/TLS > Origin Server)
- Wildcard for `*.hbprojects.app` and `hbprojects.app`
- Never committed to git (excluded in `.gitignore` and rsync)
- Must be placed on the server manually before first deploy

If they expire, regenerate in Cloudflare and copy to the server at `/opt/citadel/proxy/certs/`.

## Maintenance

### Adding a route for a new service

1. Add a `server` block in `nginx.conf` with the appropriate `server_name` and `proxy_pass`
2. Add the subdomain to the HTTP redirect `server` block at the top
3. For services needing WebSocket support, include the `Upgrade` and `Connection` headers (see the monitor/logs blocks for examples)
4. Push to main - nginx reloads automatically after deploy

### Adding a route for a demo app

1. Mount the demo's dist directory as a volume in `docker-compose.yml`
2. Add a `server` block using `root` and `try_files` instead of `proxy_pass`
3. See the music-visualiser block in `nginx.conf` for the pattern

### Debugging

Check nginx logs inside the container:
```sh
docker exec citadel-nginx cat /var/log/nginx/error.log
```

Test config syntax before reloading:
```sh
docker exec citadel-nginx nginx -t
```
