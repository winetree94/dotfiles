# Proxy and Network Boundaries

## Public ingress and Cloudflare

Public services use Cloudflare Tunnel only; direct public access to origin IPs is blocked by OPNsense. Do not create direct-origin DNS records or WAN port forwards for web or management services. OPNsense administration is available only through trusted internal/private access, not directly from the internet. The only permitted inbound port forwards are those required for VPN endpoints, with exact ports/protocols verified from current VPN configuration.

Manage Cloudflare DNS, tunnel routes, and other Cloudflare-side configuration with `cf`. Inspect current CLI help and schema before choosing commands, and verify account/profile, zone, hostname, tunnel identity, and connector health. Keep in-cluster connector manifests and backend routing in the homelab GitOps repository. Changes to OPNsense belong to its actual configuration mechanism. Tunnel failures must be fixed along that path rather than by exposing the origin or router on the WAN.

## Local network and remote sites

The homelab repository's `apps/base/proxies` manages in-cluster Traefik routes to local devices such as OPNsense, OpenMediaVault, and Proxmox. Read the resource matching the requested hostname and its sibling Traefik Cilium policy before editing.

Vivident connectivity:

- Homelab LAN `10.132.244.0/22` sends company traffic through homelab OPNsense (`10.132.244.1`). Its static routes for Vivident main `10.78.0.0/16` and legacy `10.79.0.0/16` both use gateway `10.132.246.252`.
- That gateway is the Multus/macvlan `net1` address of Pod `vivident-tailscale-router-0`, in context `homelab`, namespace `vivident`. The Pod forwards traffic through `tailscale0` to the company subnet routers using accepted Tailscale routes.
- `apps/base/vivident-tailscale-router` enables IPv4 forwarding and MASQUERADE for home LAN traffic leaving `tailscale0`; it does not advertise the home subnet (`TS_ROUTES=""`). This provides home-to-company access, not symmetric subnet advertisement.

The workload belongs to homelab, not the company cluster. Recheck its manifests and live router state when diagnosing connectivity; load `vivident-infrastructure` when the company side also needs investigation.

Tinyrack cloud services and mail may use homelab storage for backups. Inspect the owning service's backup configuration before identifying a storage backend. Changes to the source backup job stay in its owning repository; changes to the homelab destination use this skill.

For connectivity diagnosis, establish DNS, client routing, proxy listeners/endpoints, backend reachability, and relevant firewall policy. Do not open ports or alter routes solely because a README lists a historical address. Router state and actual traffic paths require current read-only inspection.
