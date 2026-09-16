# Tinyrack Cloud Recovery

Source: `~/Workspaces/tinyrack/infrastructure/readme.md`, `ansible/`, and current backup manifests. Use this procedure for requested recovery, not routine deployment.

1. Identify the Tinyrack Hetzner server through `hcloud --context winetree94`; the same context also contains the mail server. Manage replacement machines and any provider-side Floating IP assignment with `hcloud` within the recovery scope. Prepare the supported OS, SSH account, and Tailscale connectivity, updating inventory for an approved replacement. Ansible does not manage hostname, Tailscale login, or OS upgrades here.
2. Pause apps through Git by renaming `clusters/production/apps.yaml` to `apps.yaml.bak` and delivering that change. Preserve infrastructure reconciliation.
3. Configure the existing Ansible Vault securely and follow its syntax/lint/preflight/check/apply/verify workflow. It prepares host dependencies, K3s, Cilium, and the Sealed Secrets recovery key. A second apply must be idempotent.
4. Preserve established Pod/Service CIDRs. If existing configuration or sealing keys do not match the expected values, stop and diagnose; do not overwrite keys or change CIDRs to force the playbook through. Verify the single expected recovery key before encrypted resources reconcile.
5. Bootstrap Flux against `tinyrack-net/infrastructure`, branch `main`, path `clusters/production`, once Ansible verification passes. Flux adopts the Cilium release initialized by Ansible.
6. Wait for infrastructure, then restore required Longhorn volumes using the current README. Use application-level backups for databases, including CNPG recovery for Memos and Discourse. Determine the appropriate backup procedure for other active applications from their manifests.
7. Restore the app entrypoint through Git. Verify data recovery, Flux, certificates, ingress through Cloudflare Tunnel, and application health. Inspect or repair Cloudflare-side DNS and tunnel routing with `cf`; keep connector manifests in GitOps. Verify that direct public-IP access remains blocked rather than opening ports as a recovery shortcut.

The CNPG and Longhorn backup path mapping is `hetzner_fsn:tinyrack-prod/apps/` and `hetzner_fsn:tinyrack-prod/longhorn` respectively. Inspect buckets and objects with `rclone`, then restore through the relevant CNPG/Longhorn procedure. This bucket also holds mail backups under `clusters/public/`; preserve that data. Verify current targets and available recovery points; Git restores configuration, not persistent data. Load `homelab-infrastructure` only when a separately identified homelab destination itself needs work.

Keep key names, versions, networking values, and backup destinations sourced from the current repository rather than a copied command sequence. Preserve Vault-based Ansible privilege escalation and do not print secret material.
