terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "hcloud_ssh_key" "default" {
  name       = "hb-deploy-key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_firewall" "web" {
  name = "${var.server_name}-firewall"

  rule {
    description = "SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTP"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTPS"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "citadel" {
  name        = var.server_name
  image       = "ubuntu-24.04"
  server_type = var.server_type
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.default.id]

  firewall_ids = [hcloud_firewall.web.id]

  user_data = <<-EOF2
    #!/bin/bash
    set -e

    apt-get update && apt-get upgrade -y

    curl -fsSL https://get.docker.com | sh

    ufw default deny incoming
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    yes | ufw enable

    apt-get install -y fail2ban
    systemctl enable fail2ban
    systemctl start fail2ban

    apt-get install -y unattended-upgrades
    dpkg-reconfigure -f noninteractive unattended-upgrades

    mkdir -p /opt/citadel
  EOF2

  labels = {
    app = var.server_name
    env = "infrastructure"
  }
}

resource "cloudflare_record" "citadel" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  content = hcloud_server.citadel.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "citadel_vault" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain}-vault"
  content = hcloud_server.citadel.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "citadel_monitor" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain}-monitor"
  content = hcloud_server.citadel.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "citadel_logs" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomain}-logs"
  content = hcloud_server.citadel.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "music_visualiser" {
  zone_id = var.cloudflare_zone_id
  name    = "music-visualiser"
  content = hcloud_server.citadel.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}
