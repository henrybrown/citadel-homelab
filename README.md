# Citadel — Infrastructure Homelab

Central infrastructure server for hbprojects.app projects.

## Architecture

Each concern is a self-contained slice:

```
server/      → Terraform provisioning + bootstrap
vault/       → HashiCorp Vault (secrets)
monitoring/  → Uptime Kuma (uptime alerts)
logs/        → Dozzle (Docker log viewer)
proxy/       → Nginx + Certbot (SSL + routing)
```

## Quick start

### 1. Provision
```sh
source ~/.config/terraform/citadel.env
cd server/terraform
terraform init && terraform apply
```

### 2. Deploy
```sh
ssh root@$(terraform output -raw server_ip)
cd /opt && git clone https://github.com/YOUR_USERNAME/citadel-homelab.git citadel
cd citadel && bash server/bootstrap.sh
```

### 3. Initialize Vault
Visit https://vault.citadel.hbprojects.app — save unseal key + root token.

## Services

| Service | URL | Docs |
|---------|-----|------|
| Vault | vault.citadel.hbprojects.app | [vault/README.md](vault/README.md) |
| Monitor | monitor.citadel.hbprojects.app | [monitoring/README.md](monitoring/README.md) |
| Logs | logs.citadel.hbprojects.app | [logs/README.md](logs/README.md) |

## Adding a new service

1. Create a new directory with its own `docker-compose.yml`
2. Add it to the root `docker-compose.yml` includes
3. Add an nginx server block in `proxy/nginx.conf`
4. `docker compose up -d`

No DNS changes needed — wildcard record handles `*.citadel.hbprojects.app`.
