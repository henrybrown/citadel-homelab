# Logs — Dozzle

Browser-based Docker log viewer. Shows real-time logs for all containers on this server.

## Usage

Visit https://logs.citadel.hbprojects.app — no setup needed.

## Future: Loki + Grafana

To aggregate logs from multiple servers (codenames, citadel, future apps):
1. Replace Dozzle with Loki + Grafana in this slice
2. Add Promtail to each app server to ship logs to Loki
3. Query and dashboard everything in Grafana
