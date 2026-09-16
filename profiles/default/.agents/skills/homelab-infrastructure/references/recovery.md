# Homelab Recovery

Use `~/Workspaces/tinyrack/homelab/readme.md`, its `AGENTS.md`, and `ansible/` as the current operational sources. The README describes the current Cilium bootstrap; an older bootstrap summary in AGENTS.md must not be used to reinstall an obsolete network configuration.

Recovery uses the normal `clusters/production` Flux path, not a separate recovery overlay. Perform recovery only within the requested scope; it is not part of routine service diagnosis.

1. Pause application reconciliation through Git using the README's `clusters/production/apps.yaml.bak` convention and push the change. Keep infrastructure reconciliation enabled.
2. Use `ansible/` to prepare the replacement host, install K3s, bootstrap Cilium, and restore the Sealed Secrets key from Vault. Inspect inventory and use the documented preflight/check/apply/verify workflow, including a second apply for idempotency.
3. Do not bootstrap Flux until verification confirms healthy Cilium and the correct recovery key. Ansible installs the same Cilium release/values that Flux later adopts. Preserve Multus and its LAN attachments.
4. Bootstrap the `tinyrack-net/homelab` repository on branch `main`, path `clusters/production`, following the current README. Wait for infrastructure and the Longhorn backup target.
5. Restore the appropriate Ready Longhorn system backup from the same Longhorn minor version. PostgreSQL uses CNPG/Barman recovery from S3, not generic Longhorn database volume restoration.
6. Inspect any CNPG data PVCs restored by old volume backups. Before deleting them, establish the exact target, valid database backups, and recovery scope; verify their PVs and Longhorn volumes are handled as documented. Do not run a cluster-wide deletion as a routine cleanup step.
7. Restore the application entrypoint through Git. Verify CNPG recovery, Flux, certificates, ingress, storage, and core application data before restoring external traffic through Cloudflare Tunnel. Use `cf` for Cloudflare-side route/DNS checks, retain connector manifests in GitOps, and confirm OPNsense still blocks direct public service and management access. Do not add WAN port forwards beyond the configured VPN endpoints.

Use `rclone` to inspect Garage backup objects: `homelab_garage:tinyrack-homelab/clusters/tinyrack-homelab/longhorn` for Longhorn, and the current ObjectStore's `apps/` or `infrastructure/` prefix for CNPG. Bucket/object management does not replace the restore procedures above. Read current backup and bootstrap manifests for versions, storage targets, and recovery settings; do not assume data exists merely because the manifests reconciled.
