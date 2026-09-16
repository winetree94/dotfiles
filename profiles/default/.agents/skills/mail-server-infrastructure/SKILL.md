---
name: mail-server-infrastructure
description: Operate the personal Hetzner mail-server Kubernetes environment in ~/Workspaces/tinyrack/mail-server, context and SSH alias mail-server. Use for hcloud machine and Floating IP management, Stalwart, Bulwark, mail.winetree94.com, webmail.winetree94.com, Cloudflare DNS with cf, mail delivery/TLS, Flux, or Ansible recovery.
---

# Mail Server Infrastructure

## Target and scope

| Resource | Target |
| --- | --- |
| GitOps repository | `~/Workspaces/tinyrack/mail-server` |
| Kubernetes context | `mail-server` |
| SSH host | `mail-server` |
| Host automation | Repository-local `ansible/` |
| Primary mail hostname | `mail.winetree94.com` |

Honor explicit user targets; otherwise resolve from this table and state the target before infrastructure commands. Use `kubectl --context mail-server` and an explicit Flux context. Stalwart serves mail and Bulwark provides JMAP webmail. Read current manifests to determine enabled services and routes.

Manage Cloudflare-side configuration for `mail.winetree94.com`, including its DNS records, with the installed `cf` CLI. Inspect `cf --help` and relevant subcommand help or `cf schema --help` before choosing commands, and identify the intended account/profile and `winetree94.com` zone. Use explicit profile/zone selection where applicable. `cf` manages Cloudflare resources; cluster resources remain GitOps-managed, host/in-guest IP configuration remains Ansible-managed, and Hetzner resource assignment uses `hcloud`. This mail environment is not subject to the Tinyrack or homelab Tunnel-only public-service rule; preserve the mail protocols' required DNS and network behavior.

- For connectivity, DNS, TLS, or delivery diagnosis, read [references/mail-delivery.md](references/mail-delivery.md).
- For bootstrap, host replacement, or data restoration, read [references/recovery.md](references/recovery.md).

## Hetzner resources

This cluster runs on Hetzner. Use this mapping to locate resources; query current resource identities, server type/location, Floating IP assignment, PTR, and delete protection before changes.

| Resource | Identifier |
| --- | --- |
| hcloud context | `winetree94` |
| Server name / ID | `mail-server` / `115401154` |
| Floating IP name / ID | `mail-server` / `147638286` |

The same context contains the `tinyrack` server. Always select the context explicitly and match the intended resource, not just the currently active project:

```sh
hcloud context list
hcloud --context winetree94 server list -o columns=id,name,status,type,location
hcloud --context winetree94 floating-ip list -o json | jq '[.[] | {id, name, server}]'
```

Use `hcloud` for Hetzner machines and provider-side Floating IP lifecycle, assignment, and PTR configuration, checking current command help first. Preserve delete protection unless its removal is explicitly part of the requested operation. Ansible configures the assigned IP inside the guest OS; it does not replace provider-side assignment. Keep the mail Floating IP distinct from the server's primary IP and verify A/PTR/EHLO consistency after relevant changes.

Retain relevant private/internal IP addresses and subnet CIDRs in this skill and its references. Do not record external public IP addresses or public address ranges, including server primary public IPs and Floating IP values. Identify those resources by context, hostname, or resource name/ID and resolve their addresses from current provider configuration when needed.

## Object storage

Manage Object Storage buckets and objects with `rclone`, not `hcloud`. Use the backup storage mapping below and confirm it against current CNPG ObjectStores and Longhorn BackupTargets. The `hetzner_fsn:` remote uses region `fsn1` and endpoint `https://fsn1.your-objectstorage.com`; choose storage by its endpoint, independently of the server location.

| Purpose | rclone path |
| --- | --- |
| Stalwart CNPG backups | `hetzner_fsn:tinyrack-prod/clusters/public/apps/stalwart/<database-prefix>` |
| Longhorn backups | `hetzner_fsn:tinyrack-prod/clusters/public/longhorn` |

Recheck current ObjectStores for the database version and recovery source. `tinyrack-prod` is shared with the Tinyrack cluster, which uses `apps/` and `longhorn/` outside the mail prefix. Scope mail operations to `clusters/public/`; do not sync or delete the entire shared bucket for mail-only work.

The remote uses `env_auth = true` and private object/bucket ACLs. Establish credentials for this backend without printing or persisting secrets. Inspect `rclone listremotes` and use scoped listings such as `rclone lsf hetzner_fsn:tinyrack-prod/clusters/public/ --dirs-only`. Preserve private ACLs and inspect the exact impact before deletion or `rclone sync`. Backup definitions and credential references remain GitOps-managed; use CNPG/Longhorn procedures for service restoration rather than treating object copies as a complete database restore.

## Observability

Metrics, logs, and traces from `mail-server`, `homelab`, and `tinyrack` all converge on homelab and are visualized in homelab's Grafana. Use that shared Grafana instance for mail-server telemetry, scoping queries to the mail-server cluster using the actual datasource and label configuration.

Manage Grafana dashboards through the `gcx` CLI, selecting the context for homelab's Grafana. Inspect current CLI help and verify the instance, dashboard, and datasources before changes; do not assume a mail-server-local Grafana instance. Source collectors and export configuration remain owned by this repository and follow GitOps. Load `homelab-infrastructure` when investigating or changing shared ingestion, storage, Grafana, or dashboards.

## Change and verify

Inspect repository instructions, README, branch, and working-tree changes. Diagnose with read-only host and cluster inspection; preserve unrelated changes and keep credentials out of output and Git.

- Flux watches `clusters/production`. Infrastructure reconciles `infrastructure/overlays/production`; apps reconcile `apps/overlays/production` with an infrastructure dependency. Enable/disable workloads through the overlay lists and edit the appropriate bases.
- Render the changed base and affected overlay independently with `kubectl kustomize`; do not assume the bootstrap directory is a Kustomize build root.
- Follow the README's separate Helm values and application configuration conventions. Seal secrets with this repository's `tinyrack-production-key.crt`, not a certificate fetched from another cluster or the identically named file in the Tinyrack cloud repository.
- Persistent cluster changes normally go through Git and Flux. Direct live mutation requires an explicit request or clear emergency need; state the reason and exact scope first and reconcile persistent state back into Git. Check targets before destructive or production-impacting operations.
- Host and in-guest Floating IP configuration use the existing Ansible Vault/become workflow; Hetzner-side resource assignment uses `hcloud`. Do not request passwords in conversation or apply Vivident's cluster-host sudo delegation rule here.
- Verify Flux revision/readiness, rollout, storage/database health where affected, and relevant mail protocols or web endpoints. Connectivity alone does not demonstrate successful mail delivery.

Read `infrastructure/base/cilium-host-firewall/README.md` before firewall changes. Keep management access on Tailscale. Use the documented `reserved:host` PolicyAuditMode and observation procedure; audit mode is lost on Cilium restart. Emergency recovery uses Tailscale or Hetzner console access followed by a Git policy rollback and Flux reconciliation.

Load `homelab-infrastructure` for changes to homelab backup storage. Those resources stay in their owning repositories. Report the target, Git changes, any live actions, verification evidence, and remaining delivery failures without exposing message contents or credentials unnecessarily.
