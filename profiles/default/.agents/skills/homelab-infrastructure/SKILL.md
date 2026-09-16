---
name: homelab-infrastructure
description: Manage the personal homelab Kubernetes cluster, Cloudflare Tunnel public ingress with the cf CLI, local OPNsense/NAS/Proxmox infrastructure, and Tinyrack CI machines. Use for the homelab context, opnsense, openmediavault, xeon, or tinyrack homelab and ansible-github-actions-runners repositories. Excludes the tinyrack cloud cluster and mail-server workloads.
---

# Homelab Infrastructure

## Resolve the target

Retain relevant private/internal IP addresses and subnet CIDRs in this skill and its references. Do not record external public IP addresses or public address ranges; identify public-facing resources by context, SSH alias, hostname, or resource name/ID and resolve their addresses from current configuration when needed.

| Target | Repository under `~/Workspaces` | Context | SSH alias |
| --- | --- | --- | --- |
| Homelab cluster | `tinyrack/homelab` | `homelab` | `homelab` |
| Personal CI machines | `tinyrack/ansible-github-actions-runners` | None | Resolve from its inventory |

Use explicit user targets first; otherwise resolve from this table and current repository configuration. State the resolved target before infrastructure commands. Use `kubectl --context <context>` and an explicit Flux context; do not rely on the current context. A service name alone is insufficient: n8n, SearXNG, and Issuary also exist in other environments.

- For in-cluster Traefik routes, local routing, or connectivity across environments, read [references/proxy-network.md](references/proxy-network.md).
- For OPNsense, NAS, Proxmox, or CI machine work, read [references/hosts-runners.md](references/hosts-runners.md).
- For cluster bootstrap, replacement, or data restoration, read [references/recovery.md](references/recovery.md).

## Object storage

Manage buckets and objects through `rclone`. The configured remote `homelab_garage:` uses region `home` and endpoint `https://storage.intranet.winetree94.com`. It uses environment authentication (`env_auth = true`) and private object/bucket ACLs; supply credentials for the intended storage backend without printing or persisting them in the skill or Git.

Live CNPG ObjectStores and Longhorn BackupTargets were checked on 2026-09-16:

| Purpose | rclone path |
| --- | --- |
| Application database backups | `homelab_garage:tinyrack-homelab/apps/<app>/<database-prefix>` |
| Grafana database backups | `homelab_garage:tinyrack-homelab/infrastructure/monitoring/grafana-database-18` |
| Longhorn backups | `homelab_garage:tinyrack-homelab/clusters/tinyrack-homelab/longhorn` |

The repository's OpenWebUI values also configure bucket `tinyrack-homelab-openwebui-storage` on this endpoint. Check its current application configuration before operations. Use `rclone listremotes` and narrowly scoped listings such as `rclone lsf homelab_garage:tinyrack-homelab/apps/ --dirs-only`; derive exact database prefixes from current ObjectStores rather than assuming one PostgreSQL version.

Keep bucket operations separate from GitOps-managed backup configuration and CNPG/Longhorn restore procedures. Target the requested bucket/prefix, preserve private ACLs, and inspect the impact before deletion or `rclone sync`, which can remove destination objects. Garage host/service administration is a separate concern from S3 bucket management.

## Centralized observability

Metrics, logs, and traces from the `mail-server`, `homelab`, and `tinyrack` clusters all converge on homelab and are visualized in homelab's Grafana. Homelab owns the shared collection/storage infrastructure and Grafana; each source cluster retains ownership of its telemetry collectors and export configuration.

Manage Grafana dashboards through the `gcx` CLI. Inspect `gcx --help` and relevant subcommand help, select the context targeting homelab's Grafana, and verify the instance, dashboard, and datasources before changes. Discover actual datasource identifiers and cluster labels from current configuration; do not assume a separate Grafana instance per cluster. Dashboard management uses `gcx`, while Kubernetes-managed observability infrastructure changes still follow GitOps.

For missing telemetry, trace the source collector/exporter, transport, homelab ingestion/storage, and Grafana datasource/query in that order. Scope queries to the affected source cluster. Load `mail-server-infrastructure` or `tinyrack-infrastructure` when their source-side configuration needs investigation or changes.

## Change and verify

Homelab services must not expose their origin IP for direct public access. OPNsense blocks unsolicited external access; public services are reachable only through Cloudflare Tunnel. Do not publish direct-origin DNS records or open application, SSH, Kubernetes API, NAS, or hypervisor ports on the WAN. OPNsense itself must not expose its administrative interfaces externally. Inbound port forwarding is allowed only for the required VPN endpoints, limited to their actual ports and protocols; do not invent VPN ports or forward unrelated services. Preserve these restrictions during troubleshooting and recovery as well.

Use the installed `cf` CLI for Cloudflare-side DNS and Tunnel management. Discover current commands through `cf --help`, subcommand help, or `cf schema --help`; resolve the intended account/profile, zone, hostname, and tunnel before changes. Use explicit profile/zone selection where applicable. Keep Kubernetes-managed connector and origin changes in GitOps, and do not treat `cf` as the tool for OPNsense firewall configuration.

Inspect repository instructions, README, branch, and working-tree changes before editing. Use read-only cluster and host inspection to diagnose. Preserve unrelated changes and keep credentials out of output and Git.

Persistent cluster configuration normally goes through Git and Flux. Use direct live mutation only when explicitly requested or clearly required for emergency response; state the reason and scope first and reconcile persistent changes back into Git. Check exact targets before destructive or production-impacting work. Use repository-managed Ansible for supported host changes; its existing Vault/become workflow is valid. Do not request sudo passwords in conversation. Vivident's cluster-host sudo delegation rule does not apply to these personal hosts.

For the homelab cluster:

- Flux watches `clusters/production`; `infrastructure` reconciles `infrastructure/overlays/production`, then `apps` reconciles `apps/overlays/production` through `dependsOn`.
- Overlay `kustomization.yaml` files enable workloads; most overlay entries are Flux Kustomization resources pointing to `apps/base/<name>` or `infrastructure/base/<name>`.
- Render the affected overlay and the changed base separately with `kubectl kustomize`. Do not render `clusters/production` as a Kustomize root. Account for Helm/source dependencies and remote resources when validating.
- Follow the README's Helm values and ConfigMap conventions. Route-specific Traefik Cilium policies belong beside their owning app or proxy; shared entrypoint policies belong to infrastructure.
- Seal secrets with the repository's `tinyrack-homelab-secret-key.crt`. Files named `*.secret.yaml` may be JSON SealedSecrets; inspect their kind and do not replace them with plaintext Secrets. Never commit the private key.
- Deliver changes through the repository's Git workflow. Verify Flux source revision, relevant Kustomization/HelmRelease readiness, rollout, and service health. Report the target, Git changes, any live actions, and verification evidence.

Traffic from homelab to Vivident follows: LAN client -> homelab OPNsense -> `vivident-tailscale-router` Pod -> Tailscale -> company subnet router -> company LAN. See [network details](references/proxy-network.md#local-network-and-remote-sites) for the internal addresses and forwarding configuration.

The `vivident-tailscale-router` workload is owned by this homelab repository despite its name. Load `vivident-infrastructure` as well only when the company side needs investigation or changes. Load `mail-server-infrastructure` for mail workload checks and `tinyrack-infrastructure` for the cloud cluster; do not transfer ownership of their resources to homelab.
