---
name: tinyrack-infrastructure
description: Operate the Tinyrack Hetzner Kubernetes environment in ~/Workspaces/tinyrack/infrastructure, context tinyrack, SSH host tinyrack-server. Covers hcloud infrastructure management, forum.tinyrack.net and auth.tinyrack.net, Cloudflare Tunnel-only ingress with cf, Flux, backups, and Ansible recovery. Excludes general app development, homelab/CI machines, and mail-server workloads.
---

# Tinyrack Infrastructure

## Target and ownership

| Resource | Target |
| --- | --- |
| GitOps repository | `~/Workspaces/tinyrack/infrastructure` |
| Kubernetes context | `tinyrack` |
| SSH host | `tinyrack-server` |
| Host automation | Repository-local `ansible/` |

Honor an explicit user target, otherwise use this mapping and state it before infrastructure commands. Use `kubectl --context tinyrack` and an explicit Flux context. Tinyrack organization membership or a service name such as Issuary does not identify this cluster by itself; inspect the requested deployment or hostname when ambiguous.

Read repository instructions, README, branch, and working-tree changes before editing. Discover active services from `apps/overlays/production/kustomization.yaml`; README service lists can lag behind manifests. Preserve unrelated changes and keep secrets out of output and Git.

## Hetzner resources

This cluster runs on Hetzner. The following mapping was verified with read-only `hcloud` queries on 2026-09-16; recheck current resources before changes rather than treating IDs or addresses as permanent.

| Resource | Verified value |
| --- | --- |
| hcloud context | `winetree94` |
| Server name / ID | `tinyrack` / `115687231` |
| Server type / location | `cx43` / `hel1` |
| Attached Floating IP | None listed at verification |

The same hcloud context also contains `mail-server`; the context alone does not select this environment. Use explicit `hcloud --context winetree94` and match both resource identity and intended environment. Inspect with:

```sh
hcloud context list
hcloud --context winetree94 server list -o columns=id,name,status,type,location
hcloud --context winetree94 floating-ip list -o json | jq '[.[] | {id, name, server}]'
```

Use `hcloud` for Hetzner machines and provider-side Floating IP lifecycle/assignment. Inspect relevant command help before mutations. Host OS and in-guest IP configuration remain Ansible-managed, Kubernetes resources remain GitOps-managed, and Cloudflare DNS/Tunnels use `cf`. Knowing the primary IP does not permit bypassing the Tunnel-only public access policy.

Retain relevant private/internal IP addresses and subnet CIDRs in this skill and its references. Do not record external public IP addresses or public address ranges, including server primary public IPs and Floating IP values. Identify those resources by context, hostname, or resource name/ID and resolve their addresses from current provider configuration when needed.

## Object storage

Manage Object Storage buckets and objects with `rclone`, not `hcloud`. Live CNPG ObjectStores and Longhorn BackupTargets checked on 2026-09-16 use `hetzner_fsn:` (region `fsn1`, endpoint `https://fsn1.your-objectstorage.com`), even though the server is in `hel1`.

| Purpose | rclone path |
| --- | --- |
| CNPG backups | `hetzner_fsn:tinyrack-prod/apps/<app>/<database-prefix>` |
| Longhorn backups | `hetzner_fsn:tinyrack-prod/longhorn` |

Verified CNPG prefixes include `apps/memos/database`, `apps/issuary/database`, and `apps/discourse/database-15`; recheck current ObjectStores before a specific operation. The bucket is shared with mail-server, whose paths are under `clusters/public/`. Never treat the entire `tinyrack-prod` bucket as exclusive to this cluster or run a whole-bucket sync/deletion for a cluster-specific task.

`hetzner_hel:` is also configured (region `hel1`, endpoint `https://hel1.your-objectstorage.com`), but none of the inspected CNPG/Longhorn targets use it. Select remotes by the actual storage endpoint, not the machine's location. Both Hetzner remotes use `env_auth = true` and private object/bucket ACLs. Establish the correct credentials without exposing them, inspect `rclone listremotes`, and use scoped listings such as `rclone lsf hetzner_fsn:tinyrack-prod/apps/ --dirs-only`.

Preserve private ACLs and inspect the exact impact before deletion or `rclone sync`. Kubernetes backup definitions remain GitOps-managed; bucket/object management does not replace the CNPG/Longhorn recovery workflow. Storage Boxes and block Volumes are separate products.

## GitOps changes

- Flux watches `clusters/production`. Infrastructure and apps reconcile their respective `infrastructure/overlays/production` and `apps/overlays/production` directories; apps depend on infrastructure.
- Edit the relevant base plus its overlay entry where necessary. Render the changed base and affected overlay independently with `kubectl kustomize`; the Flux bootstrap directory is not a Kustomize build root.
- Keep Helm lifecycle in HelmRelease manifests and values in the repository's sibling values files/ConfigMaps. Follow existing ConfigMap hash and watch-label conventions.
- Seal new secrets with this repository's `tinyrack-production-key.crt`; the identically named certificate in the mail repository is not interchangeable. Never commit plaintext credentials or private keys.
- Deliver persistent changes through Git and Flux, then verify source revision, relevant Kustomization/HelmRelease readiness, rollout, and service health.

Use read-only cluster and host checks for diagnosis. Direct live mutation is reserved for explicit requests or clearly necessary emergency response; state the reason and exact scope first and restore persistent desired state through Git. Check targets before destructive or production-impacting actions. Supported host changes use the existing Ansible Vault/become workflow; do not request passwords in conversation. Vivident's sudo delegation rule is specific to its cluster host.

## Observability

Metrics, logs, and traces from `tinyrack`, `homelab`, and `mail-server` all converge on homelab and are visualized in homelab's Grafana. Use that shared Grafana instance for Tinyrack telemetry, scoping queries to the tinyrack cluster using the actual datasource and label configuration.

Manage Grafana dashboards through the `gcx` CLI, selecting the context for homelab's Grafana. Inspect current CLI help and verify the instance, dashboard, and datasources before changes; do not assume a Tinyrack-local Grafana instance. Source collectors and export configuration remain owned by this repository and follow GitOps. Load `homelab-infrastructure` when investigating or changing shared ingestion, storage, Grafana, or dashboards.

## Network and recovery

Public services, including `forum.tinyrack.net` and `auth.tinyrack.net`, are accessible only through Cloudflare Tunnel. Direct access through the origin's public IP is blocked. Preserve this boundary during deployment, diagnosis, and recovery: do not open public application or management ports or publish a direct-origin DNS record to bypass the tunnel. SSH and Kubernetes API management use Tailscale separately. The documented Cilium host firewall blocks public `eth0` TCP ingress.

Manage Cloudflare-side DNS and Tunnel configuration with the installed `cf` CLI. Start with `cf --help` and the relevant subcommand help or `cf schema --help` to discover the current API; do not invent tunnel command syntax. Identify the intended account/profile, zone, hostname, and tunnel before changes, using an explicit `--profile` or `--zone` where applicable. Inspect current DNS, tunnel routes, and connector health first. Cloudflare-side changes use `cf`; Kubernetes-managed connector and origin configuration still goes through this GitOps repository. Never expose API tokens or tunnel credentials in output.

Inspect the current Cloudflare connector, Traefik routes, backend endpoints, and Cilium policies to locate a failure. For Cloudflare-side configuration work, also load the relevant Cloudflare skill. Before host-firewall changes, follow the repository's `reserved:host` PolicyAuditMode and verdict-observation procedure. Audit mode does not survive Cilium restart. Emergency recovery uses Tailscale or the Hetzner console and a Git rollback; suspend/reconcile only the affected Flux resource when the documented procedure requires it.

Read [references/recovery.md](references/recovery.md) for bootstrap, host replacement, or data restoration. Backup destination changes on homelab require `homelab-infrastructure`; application backup jobs remain owned here. Mail workloads belong to `mail-server-infrastructure`.

Report the resolved target, Git changes, any live actions, and verification evidence, including incomplete delivery or recovery steps.
