# Citadel

Citadel is the central infrastructure server for all hbprojects.app projects. It runs on a single Hetzner VPS and hosts shared services (secrets management, uptime monitoring, log viewing) alongside static demo apps. The server and all supporting resources (DNS, firewall, access policies) are provisioned with Terraform as infrastructure as code. Everything is deployed automatically via GitHub Actions on push to main.

## How it works

The server runs Docker Compose with an nginx reverse proxy in front. Each service is a self-contained directory with its own `docker-compose.yml`. Cloudflare handles DNS and SSL termination (origin certificates), and Cloudflare Access gates admin services behind email OTP.

```
server/      Terraform provisioning (Hetzner + Cloudflare DNS + Access policies)
vault/       HashiCorp Vault for secrets management
monitoring/  Uptime Kuma for uptime alerts
logs/        Dozzle for real-time Docker log viewing
proxy/       Nginx reverse proxy (SSL + subdomain routing)
access/      Cloudflare Zero Trust configuration docs
demos/       Static demo apps served directly by nginx
```

## Services

| Service | URL | Purpose |
|---------|-----|---------|
| Vault | citadel-vault.hbprojects.app | Store and retrieve secrets for all projects |
| Monitor | citadel-monitor.hbprojects.app | Uptime checks with alerting |
| Logs | citadel-logs.hbprojects.app | Real-time Docker container logs |
| Music Visualiser | music-visualiser.hbprojects.app | Demo app (static site) |

## Deployment

Deployments are fully automated. Pushing to `main` triggers a GitHub Actions workflow that:

1. Rsyncs the repo to the server at `/opt/citadel/` (excluding certs, terraform state, and demo dist files)
2. Pulls updated Docker images
3. Runs `docker compose up -d` to apply changes
4. Reloads nginx to pick up config changes

The workflow uses org-level GitHub secrets: `CITADEL_DEPLOY_KEY`, `CITADEL_DEPLOY_HOST`, and `DEPLOY_USER`.

## Initial setup

Only needed once when provisioning a new server from scratch.

### 1. Provision infrastructure
```sh
source ~/.config/terraform/citadel.env
cd server/terraform
terraform init && terraform apply
```

This creates the Hetzner server, Cloudflare DNS records, and Access policies.

### 2. First deploy
```sh
ssh root@$(terraform output -raw server_ip)
cd /opt && git clone https://github.com/henrybrown/citadel-homelab.git citadel
cd citadel && bash server/bootstrap.sh
```

### 3. Initialize Vault
Visit https://citadel-vault.hbprojects.app, choose 1 key share / 1 threshold, and save the unseal key and root token. See [vault/README.md](vault/README.md) for details.

## Maintenance

### Adding a new infrastructure service

1. Create a new directory with its own `docker-compose.yml`
2. Add it to the root `docker-compose.yml` includes
3. Add an nginx server block in `proxy/nginx.conf`
4. Add the subdomain to the HTTP redirect block in `proxy/nginx.conf`
5. If using a `citadel-*` subdomain, no DNS changes needed (wildcard covers it)
6. If using a top-level subdomain, add a Cloudflare DNS A record in `server/terraform/main.tf` and run `terraform apply`
7. Optionally add a Cloudflare Access policy in `server/terraform/access.tf`
8. Push to main

### Adding a demo project

Demo projects are static sites (built in their own repos) served directly by the main nginx container. No additional Docker containers needed.

1. Create `demos/my-app/` with an empty `dist/` directory
2. Mount the dist into nginx in `proxy/docker-compose.yml`:
   ```yaml
   - ../demos/my-app/dist:/usr/share/nginx/demos/my-app:ro
   ```
3. Add a server block in `proxy/nginx.conf`:
   ```nginx
   server {
       listen 443 ssl;
       server_name my-app.hbprojects.app;

       ssl_certificate /etc/nginx/certs/origin.pem;
       ssl_certificate_key /etc/nginx/certs/origin-key.pem;

       root /usr/share/nginx/demos/my-app;
       index index.html;

       location / {
           limit_req zone=general burst=20 nodelay;
           try_files $uri $uri/ /index.html;
       }
   }
   ```
4. Add the subdomain to the HTTP redirect block in `proxy/nginx.conf`
5. Add a Cloudflare DNS A record in `server/terraform/main.tf` and run `terraform apply`
6. Push to main

The demo app's own repo needs a GitHub Actions workflow that builds and rsyncs its `dist/` to `/opt/citadel/demos/my-app/dist/` on the server. See [music-visualiser](https://github.com/henrybrown/music-visualiser) for a working example.

### SSL certificates

SSL uses Cloudflare origin certificates (wildcard for `*.hbprojects.app`). These are stored at `proxy/certs/` on the server and are never committed to git. If they expire, regenerate them in the Cloudflare dashboard under SSL/TLS > Origin Server and place them on the server manually.

### Vault unsealing

Vault seals itself on every container restart. After a server reboot or deploy that restarts the vault container, unseal it via the UI or CLI:
```sh
docker exec -it citadel-vault vault operator unseal YOUR_UNSEAL_KEY
```
